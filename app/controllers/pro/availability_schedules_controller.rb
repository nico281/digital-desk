module Pro
  class AvailabilitySchedulesController < BaseController
    before_action :require_professional!
    before_action :set_schedule, only: [ :edit, :update, :destroy ]

    DAY_NAMES = %w[Domingo Lunes Martes Miércoles Jueves Viernes Sábado].freeze

    def index
      @schedules = @professional.availability_schedules.ordered
      @schedules_by_day = @schedules.group_by(&:day_of_week)
      @blocks_count = @professional.availability_blocks.available.upcoming.count
    end

    def update_settings
      if @professional.update(block_settings_params)
        BlockGeneratorJob.perform_later("professional", @professional.id)
        redirect_to pro_availability_schedules_path, notice: "Configuración actualizada. Regenerando bloques..."
      else
        redirect_to pro_availability_schedules_path, alert: @professional.errors.full_messages.join(", ")
      end
    end

    def new
      @schedule = @professional.availability_schedules.build
    end

    def create
      @schedule = @professional.availability_schedules.build(schedule_params)

      if @schedule.save
        redirect_to pro_availability_schedules_path, notice: "Horario agregado"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @schedule.update(schedule_params)
        redirect_to pro_availability_schedules_path, notice: "Horario actualizado"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @schedule.destroy
      redirect_to pro_availability_schedules_path, notice: "Horario eliminado"
    end

    private

    def set_schedule
      @schedule = @professional.availability_schedules.find(params[:id])
    end

    def schedule_params
      params.require(:availability_schedule).permit(:day_of_week, :start_time, :end_time)
    end

    def block_settings_params
      params.require(:professional).permit(:block_duration_minutes, :buffer_minutes)
    end
  end
end
