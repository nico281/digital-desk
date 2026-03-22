class Professional < ApplicationRecord
  belongs_to :user
  has_many :services, dependent: :destroy
  has_many :availability_schedules, dependent: :destroy
  has_many :availability_blocks, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :professional_categories, dependent: :destroy
  has_many :categories, through: :professional_categories
  has_one :cancellation_policy, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :headline, length: { maximum: 100 }
  validates :rating_avg, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :rating_count, numericality: { greater_than_or_equal_to: 0 }

  scope :verified, -> { where(verified: true) }
  scope :by_rating, -> { order(rating_avg: :desc) }

  def full_name
    user.name
  end

  def update_rating!(new_rating)
    current_total = rating_count * rating_avg
    new_count = rating_count + 1
    new_avg = (current_total + new_rating) / new_count.to_f

    update(rating_avg: new_avg.round(2), rating_count: new_count)
  end
end
