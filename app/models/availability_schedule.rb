class AvailabilitySchedule < ApplicationRecord
  belongs_to :professional
  has_many :availability_blocks, dependent: :nullify

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  scope :ordered, -> { order(:day_of_week, :start_time) }

  after_commit :enqueue_block_regeneration, on: [ :create, :update ]
  after_destroy :cleanup_future_blocks

  private

  def end_time_after_start_time
    return if start_time.nil? || end_time.nil?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def enqueue_block_regeneration
    BlockGeneratorJob.perform_later("schedule", id)
  end

  def cleanup_future_blocks
    availability_blocks
      .where(status: :available)
      .where("date >= ?", Date.tomorrow)
      .delete_all
  end
end
