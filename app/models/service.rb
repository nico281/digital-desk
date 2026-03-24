class Service < ApplicationRecord
  belongs_to :professional
  belongs_to :category, optional: true

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validate :duration_fits_in_block

  def duration_fits_in_block
    return unless professional&.block_duration_minutes
    if duration_minutes.to_i > professional.block_duration_minutes
      errors.add(:duration_minutes, "no puede superar la duración del bloque (#{professional.block_duration_minutes} min)")
    end
  end

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category_id) { where(category_id:) }

  def net_price
    price
  end
end
