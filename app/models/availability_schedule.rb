class AvailabilitySchedule < ApplicationRecord
  belongs_to :professional

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  scope :ordered, -> { order(:day_of_week, :start_time) }

  private

  def end_time_after_start_time
    return if start_time.nil? || end_time.nil?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
