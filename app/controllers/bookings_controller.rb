class BookingsController < ApplicationController
  before_action :require_authentication!, only: [ :show, :confirm, :cancel, :livekit_token, :room ]
  before_action :set_booking, only: [ :show, :confirm, :cancel, :livekit_token, :room ]

  def show
    @video_available = false
    if @booking.confirmed? && @booking.meeting_room_id.present?
      block = @booking.availability_block
      booking_start = block.date.to_datetime + block.start_time.seconds_since_midnight.seconds
      booking_end = block.date.to_datetime + block.end_time.seconds_since_midnight.seconds
      now = Time.current
      @video_available = now >= (booking_start - 15.minutes) && now <= booking_end
    end
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
    unless is_booking_professional?(@booking)
      redirect_to @booking, alert: "Solo el profesional puede confirmar"
      return
    end

    @booking.confirm!
    redirect_to @booking, notice: "Reserva confirmada"
  end

  def cancel
    unless can_modify_booking?(@booking)
      redirect_to @booking, alert: "No podés cancelar esta reserva"
      return
    end

    unless @booking.pending? || @booking.confirmed?
      redirect_to @booking, alert: "No se puede cancelar esta reserva"
      return
    end

    @booking.cancel!
    BookingMailer.booking_cancelled(@booking, cancelled_by: :client).deliver_later
    redirect_to dashboard_path, notice: "Reserva cancelada"
  end

  def room
    unless @booking.confirmed? && @booking.meeting_room_id.present?
      redirect_to @booking, alert: "La videollamada no está disponible"
      return
    end

    unless can_modify_booking?(@booking)
      redirect_to @booking, alert: "No tenés acceso a esta videollamada"
      return
    end

    block = @booking.availability_block
    booking_start = block.date.to_datetime + block.start_time.seconds_since_midnight.seconds
    booking_end = block.date.to_datetime + block.end_time.seconds_since_midnight.seconds
    now = Time.current

    unless now >= (booking_start - 15.minutes) && now <= booking_end
      redirect_to @booking, alert: "La videollamada estará disponible 15 minutos antes del turno"
      return
    end

    @other_participant = current_user == @booking.client ? @booking.professional.user : @booking.client
    render layout: "video"
  end

  def livekit_token
    unless @booking.confirmed?
      render json: { error: "Booking not confirmed" }, status: :forbidden
      return
    end

    unless can_modify_booking?(@booking)
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    identity = is_booking_client?(@booking) ? "client_#{@booking.client.id}" : "pro_#{@booking.professional.id}"
    name = current_user.name

    token = LivekitTokenGenerator.generate(
      room_name: @booking.meeting_room_id,
      participant_name: name,
      participant_identity: identity
    )

    render json: { token: token, url: ENV["LIVEKIT_URL"] }
  end

  private

  def set_booking
    @booking = Booking.includes(
      :service, :availability_block, :payment,
      { professional: :user }, :client,
      conversation: [ :chat_read_markers, :messages ]
    ).find(params[:id])
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

      if professional.require_confirmation?
        schedule_confirmation_deadline(@booking)
        BookingMailer.booking_created(@booking).deliver_later
      else
        @booking.confirm!
        @booking.update!(meeting_room_id: "booking_#{@booking.id}")
        BookingMailer.booking_confirmed(@booking).deliver_later
      end
    end

    notice = professional.require_confirmation? ? "Reserva creada. Esperando confirmación del profesional." : "Reserva confirmada"
    redirect_to @booking, notice: notice
  rescue ActiveRecord::RecordNotFound
    redirect_to professional_path(professional), alert: "Ese horario ya no está disponible"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to professional_path(professional), alert: e.message
  end

  def schedule_confirmation_deadline(booking)
    deadline = ConfirmationDeadlineCalculator.calculate(booking)
    return unless deadline

    booking.update!(confirmation_deadline_at: deadline)

    ConfirmationDeadlineJob.set(wait_until: deadline).perform_later(booking.id)

    reminder_at = deadline - 15.minutes
    if reminder_at > Time.current
      DeadlineReminderJob.set(wait_until: reminder_at).perform_later(booking.id)
    end
  end
end
