class Service < ApplicationRecord
  belongs_to :professional
  belongs_to :category, optional: true

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category_id) { where(category_id:) }

  def net_price
    price
  end
end
