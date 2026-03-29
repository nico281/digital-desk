class Service < ApplicationRecord
  belongs_to :professional
  belongs_to :category, optional: true

  # Validaciones mejoradas
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_nil: true
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 100000 }
  validates :duration_minutes, presence: true, numericality: {
    greater_than: 0,
    less_than: 480,
    only_integer: true
  }
  validate :duration_fits_in_block

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category_id) { where(category_id:) }

  def duration_fits_in_block
    return unless professional&.block_duration_minutes
    if duration_minutes.to_i > professional.block_duration_minutes
      errors.add(:duration_minutes, "no puede superar la duración del bloque (#{professional.block_duration_minutes} min)")
    end
  end

  def net_price
    price
  end
end
