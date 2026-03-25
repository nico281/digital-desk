class ConfirmationDeadlineJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking&.pending?

    booking.cancel!

    BookingMailer.booking_cancelled(booking, cancelled_by: :deadline).deliver_later
  end
end
