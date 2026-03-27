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
  has_many :conversations, dependent: :destroy
  has_one_attached :intro_video

  CURRENCIES = {
    "UYU" => { unit: "$U", name: "Peso uruguayo" },
    "ARS" => { unit: "$", name: "Peso argentino" },
    "USD" => { unit: "US$", name: "Dólar" },
    "BRL" => { unit: "R$", name: "Real" },
    "EUR" => { unit: "€", name: "Euro" }
  }.freeze

  validates :currency, inclusion: { in: CURRENCIES.keys }
  validates :headline, length: { maximum: 100 }
  validates :rating_avg, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :rating_count, numericality: { greater_than_or_equal_to: 0 }
  validates :block_duration_minutes, inclusion: { in: [ 15, 30, 45, 60 ] }
  validates :buffer_minutes, inclusion: { in: [ 0, 5, 10, 15 ] }

  scope :verified, -> { where(verified: true) }
  scope :by_rating, -> { order(rating_avg: :desc) }

  def setup_complete?
    setup_completed_at.present?
  end

  # Returns the next incomplete wizard step (1, 2 or 3), or nil if all done.
  def next_setup_step
    return 1 unless headline.present?
    return 2 unless services.any?
    return 3 unless availability_schedules.any?
    nil
  end

  def mark_setup_complete!
    update_column(:setup_completed_at, Time.current) unless setup_complete?
  end

  def full_name
    user.name
  end

  def generate_blocks!(from: Date.tomorrow, to: 4.weeks.from_now.to_date)
    BlockGenerator.new(self).generate(from: from, to: to)
  end

  def regenerate_all_blocks!
    BlockGenerator.new(self).regenerate_all
  end

  def update_rating!(new_rating)
    current_total = rating_count * rating_avg
    new_count = rating_count + 1
    new_avg = (current_total + new_rating) / new_count.to_f

    update(rating_avg: new_avg.round(2), rating_count: new_count)
  end
end
