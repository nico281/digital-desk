class BookingMailer < ApplicationMailer
  def booking_created(booking)
    @booking = reload_booking(booking)
    @professional = @booking.professional
    @client = @booking.client
    @service = @booking.service

    mail(
      to: @professional.user.email,
      subject: "Nueva reserva: #{@service.title}"
    )
  end

  def booking_confirmed(booking)
    @booking = reload_booking(booking)
    @professional = @booking.professional
    @client = @booking.client
    @service = @booking.service

    mail(
      to: @client.email,
      subject: "Reserva confirmada: #{@service.title}"
    )
  end

  def booking_cancelled(booking, cancelled_by:)
    @booking = reload_booking(booking)
    @professional = @booking.professional
    @client = @booking.client
    @service = @booking.service
    @cancelled_by = cancelled_by

    if cancelled_by == :deadline
      recipients = [ @professional.user.email, @client.email ]
    else
      recipients = cancelled_by == :client ? [ @professional.user.email ] : [ @client.email ]
    end

    mail(
      to: recipients,
      subject: "Reserva cancelada: #{@service.title}"
    )
  end

  def booking_rejected(booking)
    @booking = reload_booking(booking)
    @professional = @booking.professional
    @client = @booking.client
    @service = @booking.service

    mail(
      to: @client.email,
      subject: "Reserva no aceptada: #{@service.title}"
    )
  end

  def confirmation_deadline_approaching(booking)
    @booking = reload_booking(booking)
    @professional = @booking.professional
    @service = @booking.service
    @deadline = @booking.confirmation_deadline_at

    mail(
      to: @professional.user.email,
      subject: "Confirmá tu reserva: #{@service.title}"
    )
  end

  private

  def reload_booking(booking)
    Booking.includes(professional: :user, :client, :service, :availability_block).find(booking.id)
  end
end
