module Pro
  class AvailabilitySchedulesController < BaseController
    before_action :require_setup_complete!
    before_action :set_schedule, only: [ :edit, :update, :destroy ]

    DAY_NAMES = %w[Domingo Lunes Martes Miércoles Jueves Viernes Sábado].freeze

    PRESETS = {
      "office" => {
        label: "Lun–Vie, 9–18",
        schedules: (1..5).map { |d| { day_of_week: d, start_time: "09:00", end_time: "18:00" } }
      },
      "split" => {
        label: "Lun–Vie, 9–13 / 14–18",
        schedules: (1..5).flat_map { |d| [
          { day_of_week: d, start_time: "09:00", end_time: "13:00" },
          { day_of_week: d, start_time: "14:00", end_time: "18:00" }
        ]}
      },
      "mornings" => {
        label: "Lun–Vie, 8–12",
        schedules: (1..5).map { |d| { day_of_week: d, start_time: "08:00", end_time: "12:00" } }
      },
      "afternoons" => {
        label: "Lun–Vie, 14–20",
        schedules: (1..5).map { |d| { day_of_week: d, start_time: "14:00", end_time: "20:00" } }
      },
      "saturdays" => {
        label: "Sáb, 9–13",
        schedules: [ { day_of_week: 6, start_time: "09:00", end_time: "13:00" } ]
      }
    }.freeze

    def index
      @schedules = @professional.availability_schedules.ordered
      @schedules_by_day = @schedules.group_by(&:day_of_week)
      @blocks_count = @professional.availability_blocks.available.upcoming.count
      @presets = PRESETS
    end

    def update_settings
      if @professional.update(block_settings_params)
        BlockGeneratorJob.perform_later("professional", @professional.id)
        redirect_to pro_availability_schedules_path, notice: "Configuración actualizada. Regenerando bloques..."
      else
        @schedules = @professional.availability_schedules.ordered
        @schedules_by_day = @schedules.group_by(&:day_of_week)
        @blocks_count = @professional.availability_blocks.available.upcoming.count
        render :index, status: :unprocessable_entity
      end
    end

    def new
      @schedule = @professional.availability_schedules.build
    end

    def create
      @schedule = @professional.availability_schedules.build(schedule_params)

      if @schedule.save
        reload_schedules
        respond_to do |format|
          format.html { redirect_to pro_availability_schedules_path, notice: "Horario agregado" }
          format.turbo_stream { flash.now[:notice] = "Horario agregado" }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @schedule.update(schedule_params)
        reload_schedules
        respond_to do |format|
          format.html { redirect_to pro_availability_schedules_path, notice: "Horario actualizado" }
          format.turbo_stream { flash.now[:notice] = "Horario actualizado" }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @schedule.destroy
      reload_schedules
      respond_to do |format|
        format.html { redirect_to pro_availability_schedules_path, notice: "Horario eliminado" }
        format.turbo_stream { flash.now[:notice] = "Horario eliminado" }
      end
    end

    def reset
      count = @professional.availability_schedules.count
      if count > 0
        @professional.availability_schedules.destroy_all
        reload_schedules
        respond_to do |format|
          format.html { redirect_to pro_availability_schedules_path, notice: "Se eliminaron #{count} horario(s)" }
          format.turbo_stream { flash.now[:notice] = "Se eliminaron #{count} horario(s)" }
        end
      else
        redirect_to pro_availability_schedules_path
      end
    end

    def batch
      schedules_params = params.require(:schedules)
      created = 0

      AvailabilitySchedule.transaction do
        schedules_params.each do |sp|
          schedule = @professional.availability_schedules.build(sp.permit(:day_of_week, :start_time, :end_time))
          schedule.save && created += 1
        end
      end

      reload_schedules
      respond_to do |format|
        format.html { redirect_to pro_availability_schedules_path, notice: "#{created} horario(s) creado(s)" }
        format.turbo_stream { flash.now[:notice] = "#{created} horario(s) creado(s)" }
      end
    end

    private

    def reload_schedules
      @schedules = @professional.availability_schedules.ordered
      @schedules_by_day = @schedules.group_by(&:day_of_week)
    end

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
