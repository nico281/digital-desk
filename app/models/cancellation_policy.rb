class CancellationPolicy < ApplicationRecord
  belongs_to :professional

  validates :free_cancel_hours_before, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :late_cancel_refund_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def free_cancellation_deadline(booking_date)
    booking_date - free_cancel_hours_before.hours
  end

  def can_cancel_for_free?(booking)
    return false if booking.nil?
    Time.current < free_cancellation_deadline(booking.date)
  end
end
