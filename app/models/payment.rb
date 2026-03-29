class Payment < ApplicationRecord
  enum :status, pending: 0, approved: 1, rejected: 2, refunded: 3

  belongs_to :booking

  # Validaciones mejoradas
  validates :amount, presence: true, numericality: { greater_than: 0, less_than: 1_000_000 }
  validates :currency, presence: true, inclusion: { in: Professional::CURRENCIES.keys }
  validates :mp_payment_id, uniqueness: { allow_nil: true }
  validate :booking_must_not_have_payment, on: :create
  validate :amount_must_match_booking, if: -> { booking && amount }

  scope :approved, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }

  def approved?
    status == "approved"
  end

  def refund!
    update!(status: :refunded)
  end

  private

  def booking_must_not_have_payment
    return unless booking
    if booking.payment && booking.payment != self
      errors.add(:booking, "ya tiene un pago asociado")
    end
  end

  def amount_must_match_booking
    return unless booking && amount
    expected = booking.service.price
    if amount != expected
      errors.add(:amount, "no coincide con el precio del servicio (#{expected})")
    end
  end
end
