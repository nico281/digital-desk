class Payment < ApplicationRecord
  enum :status, pending: 0, approved: 1, rejected: 2, refunded: 3

  belongs_to :booking

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true

  scope :approved, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }

  def approved?
    status == "approved"
  end

  def refund!
    update!(status: :refunded)
  end
end
