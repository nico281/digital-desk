module Pro
  class SetupsController < BaseController
    def show
      @professional ||= current_user.build_professional
      @categories = Category.root.ordered
    end

    def update
      @professional ||= current_user.build_professional
      @professional.assign_attributes(professional_params)

      ActiveRecord::Base.transaction do
        @professional.save!
        @professional.category_ids = Array(params[:professional][:category_ids])
        current_user.professional! unless current_user.professional?
        @professional.create_cancellation_policy! unless @professional.cancellation_policy
      end

      # Intro video
      if params[:remove_intro_video] == "1"
        @professional.intro_video.purge
      elsif params[:professional_intro_video].present?
        @professional.intro_video.attach(params[:professional_intro_video])
      end

      redirect_to pro_services_path, notice: "Perfil profesional guardado"
    rescue ActiveRecord::RecordInvalid
      @categories = Category.root.ordered
      render :show, status: :unprocessable_entity
    end

    private

    def professional_params
      params.require(:professional).permit(:headline, :bio, :currency)
    end
  end
end
