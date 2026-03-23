module Pro
  class AvailabilitySchedulesController < BaseController
    before_action :require_professional!
    before_action :set_schedule, only: [ :edit, :update, :destroy ]

    DAY_NAMES = %w[Domingo Lunes Martes Miércoles Jueves Viernes Sábado].freeze

    def index
      @schedules = @professional.availability_schedules.ordered
      @schedules_by_day = @schedules.group_by(&:day_of_week)
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
  end
end
