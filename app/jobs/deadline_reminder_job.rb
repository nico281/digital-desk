class DeadlineReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking&.pending?

    BookingMailer.confirmation_deadline_approaching(booking).deliver_later
  end
end
