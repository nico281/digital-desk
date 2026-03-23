module Pro
  class AvailabilityBlocksController < BaseController
    before_action :require_professional!

    def create
      @block = @professional.availability_blocks.build(block_params)
      @block.status = :blocked

      if @block.save
        redirect_to pro_availability_schedules_path, notice: "Fecha bloqueada"
      else
        redirect_to pro_availability_schedules_path, alert: "No se pudo bloquear: #{@block.errors.full_messages.join(', ')}"
      end
    end

    def destroy
      block = @professional.availability_blocks.blocked.find(params[:id])
      block.destroy
      redirect_to pro_availability_schedules_path, notice: "Bloqueo eliminado"
    end

    private

    def block_params
      params.permit(:date, :start_time, :end_time)
    end
  end
end
