class BookingsController < ApplicationController
  before_action :require_authentication!
  before_action :set_booking, only: [ :show, :confirm, :cancel ]

  def show
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.client = current_user

    if @booking.save
      redirect_to @booking, notice: "Reserva creada exitosamente"
    else
      redirect_to professionals_path, alert: "No se pudo crear la reserva"
    end
  end

  def confirm
    @booking.confirm!
    redirect_to @booking, notice: "Reserva confirmada"
  end

  def cancel
    @booking.cancel!
    redirect_to @booking, notice: "Reserva cancelada"
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:professional_id, :service_id, :availability_block_id)
  end
end
