class User < ApplicationRecord
  has_one :professional, dependent: :destroy
  has_many :bookings_as_client, class_name: "Booking", foreign_key: :client_id, dependent: :destroy
  has_many :reviews_as_client, class_name: "Review", foreign_key: :client_id, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, client: 0, professional: 1

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def can_provide_services?
    professional?
  end
end
