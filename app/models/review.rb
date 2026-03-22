class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :client, class_name: 'User'
  belongs_to :professional

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  validates :booking_id, uniqueness: true
  validate :booking_completed
  validate :client_is_booking_client

  scope :recent, -> { order(created_at: :desc) }

  after_create :update_professional_rating

  private

  def booking_completed
    return unless booking
    errors.add(:booking, 'must be completed to review') unless booking.completed?
  end

  def client_is_booking_client
    return unless booking && client
    errors.add(:client, 'must be the booking client') unless booking.client_id == client.id
  end

  def update_professional_rating
    professional.update_rating!(rating)
  end
end
