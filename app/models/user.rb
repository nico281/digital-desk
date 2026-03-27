class User < ApplicationRecord
  has_one :professional, dependent: :destroy
  has_many :bookings_as_client, class_name: "Booking", foreign_key: :client_id, dependent: :destroy
  has_many :reviews_as_client, class_name: "Review", foreign_key: :client_id, dependent: :destroy
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :conversations_as_client, class_name: "Conversation", foreign_key: :client_id, dependent: :destroy
  has_one_attached :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  enum :role, client: 0, professional: 1

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, unless: :from_omniauth?

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def from_omniauth?
    provider.present?
  end

  def can_provide_services?
    professional?
  end
end
