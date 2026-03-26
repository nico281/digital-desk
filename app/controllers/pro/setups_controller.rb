module Pro
  class SetupsController < BaseController
    STEPS = [ nil, :profile, :service, :availability ].freeze

    def show
      @wizard = !current_user.professional&.setup_complete? || params[:step].present?

      if @wizard
        @step = if params[:step].present?
                  params[:step].to_i.clamp(1, 3)
                else
                  current_user.professional&.next_setup_step || 1
                end
      else
        @step = params[:step]&.to_i&.clamp(1, 3) || 1
      end

      case @step
      when 1
        @professional = current_user.professional || current_user.build_professional
        @categories = Category.root.ordered
      when 2
        unless current_user.professional&.persisted?
          redirect_to pro_setup_path(step: 1)
          return
        end
        @professional = current_user.professional
        @service = @professional.services.build
        @categories = Category.ordered
      when 3
        unless current_user.professional&.persisted?
          redirect_to pro_setup_path(step: 1)
          return
        end
        @professional = current_user.professional
        @presets = AvailabilitySchedulesController::PRESETS
      end
    end

    def update
      @step = params[:step].to_i.clamp(1, 3)

      case @step
      when 1 then update_profile
      when 2 then update_service
      when 3 then update_availability
      else redirect_to pro_setup_path
      end
    end

    private

    def update_profile
      @professional ||= current_user.build_professional
      @professional.assign_attributes(professional_params)
      @categories = Category.root.ordered

      ActiveRecord::Base.transaction do
        @professional.save!
        @professional.category_ids = Array(params[:professional][:category_ids])
        current_user.professional! unless current_user.professional?
        @professional.create_cancellation_policy! unless @professional.cancellation_policy
      end

      handle_intro_video

      if !@professional.setup_complete?
        redirect_to pro_setup_path(step: 2), notice: "Perfil guardado"
      else
        redirect_to pro_setup_path, notice: "Perfil actualizado"
      end
    rescue ActiveRecord::RecordInvalid
      @step = 1
      render :show, status: :unprocessable_entity
    end

    def update_service
      @professional = current_user.professional

      # Si todos los campos están vacíos, avanzar sin crear
      if service_params.values.all?(&:blank?)
        redirect_to pro_setup_path(step: 3)
        return
      end

      @service = @professional.services.build(service_params)

      if @service.save
        redirect_to pro_setup_path(step: 3), notice: "Servicio creado"
      else
        @step = 2
        @categories = Category.ordered
        render :show, status: :unprocessable_entity
      end
    end

    def update_availability
      @professional = current_user.professional
      return redirect_to pro_setup_path unless @professional&.persisted?

      created_schedules = false

      if params[:professional].present?
        @professional.update(block_settings_params)
      end

      if params[:preset].present?
        preset = AvailabilitySchedulesController::PRESETS[params[:preset]]
        if preset
          AvailabilitySchedule.transaction do
            preset[:schedules].each do |s|
              @professional.availability_schedules.create!(s)
            end
          end
          created_schedules = true
        end
      end

      if created_schedules && @professional.block_duration_minutes.present?
        BlockGeneratorJob.perform_later("professional", @professional.id)
      end

      @professional.mark_setup_complete!
      redirect_to dashboard_path, notice: "¡Todo listo! Ya podés recibir reservas"
    rescue ActiveRecord::RecordInvalid
      @step = 3
      @presets = AvailabilitySchedulesController::PRESETS
      render :show, status: :unprocessable_entity
    end

    def handle_intro_video
      if params[:remove_intro_video] == "1"
        @professional.intro_video.purge
      elsif params[:professional_intro_video].present?
        @professional.intro_video.attach(params[:professional_intro_video])
      end
    end

    def professional_params
      params.require(:professional).permit(:headline, :bio, :currency)
    end

    def service_params
      params.require(:service).permit(:title, :description, :price, :duration_minutes, :category_id)
    end

    def block_settings_params
      params.require(:professional).permit(:block_duration_minutes, :buffer_minutes)
    end
  end
end
