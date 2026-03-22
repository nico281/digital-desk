class AvailabilityBlock < ApplicationRecord
  enum :status, available: 0, booked: 1, blocked: 2

  belongs_to :professional
  belongs_to :booking, optional: true

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :booking_consistency

  scope :available, -> { where(status: :available) }
  scope :for_date, ->(date) { where(date:) }
  scope :upcoming, -> { where('date >= ?', Date.today) }

  def available?
    status == 'available'
  end

  def book!(booking)
    with_lock do
      raise 'Block already booked' if booked?
      update!(status: :booked, booking:)
    end
  end

  private

  def end_time_after_start_time
    return if start_time.nil? || end_time.nil?
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end

  def booking_consistency
    if booked? && booking.nil?
      errors.add(:booking, 'must be present when status is booked')
    elsif !booked? && booking.present?
      errors.add(:booking, 'must be nil when status is not booked')
    end
  end
end
