class AvailabilityBlock < ApplicationRecord
  enum :status, available: 0, booked: 1, blocked: 2

  belongs_to :professional
  belongs_to :availability_schedule, optional: true
  belongs_to :booking, optional: true

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  scope :available, -> { where(status: :available) }
  scope :for_date, ->(date) { where(date:) }
  scope :upcoming, -> { where("date >= ?", Date.today) }
  scope :with_lead_time, ->(hours) {
    cutoff = Time.current + hours.hours
    where("date > :today OR (date = :today AND start_time > :cutoff)",
      today: Date.current, cutoff: cutoff.strftime("%H:%M:%S"))
  }

  def book!(booking)
    update!(status: :booked, booking: booking)
  end

  def release!
    update!(status: :available, booking: nil)
  end

  private

  def end_time_after_start_time
    return if start_time.nil? || end_time.nil?
    errors.add(:end_time, "debe ser posterior a la hora de inicio") if end_time <= start_time
  end
end
