class BookingsController < ApplicationController
  before_action :require_authentication!, only: [ :show, :confirm, :cancel ]
  before_action :set_booking, only: [ :show, :confirm, :cancel ]

  def show
  end

  def create
    # Si no está logueado, guardar intención y mandar al login
    unless user_signed_in?
      session[:pending_booking] = booking_params.to_h
      redirect_to new_user_session_path, alert: "Iniciá sesión para confirmar tu reserva"
      return
    end

    complete_booking(booking_params)
  end

  # Completa la reserva pendiente después del login
  def complete_pending
    pending = session.delete(:pending_booking)

    unless pending
      redirect_to root_path and return
    end

    complete_booking(ActionController::Parameters.new(pending).permit(:professional_id, :service_id, :availability_block_id))
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

  def complete_booking(params)
    professional = Professional.find(params[:professional_id])
    service = professional.services.find(params[:service_id])
    block = professional.availability_blocks.available.find(params[:availability_block_id])

    ActiveRecord::Base.transaction do
      @booking = Booking.create!(
        professional: professional,
        service: service,
        availability_block: block,
        client: current_user
      )
      block.book!(@booking)
    end

    redirect_to @booking, notice: "Reserva creada exitosamente"
  rescue ActiveRecord::RecordNotFound
    redirect_to professional_path(professional), alert: "Ese horario ya no está disponible"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to professional_path(professional), alert: e.message
  end
end
