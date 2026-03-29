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

  # Validaciones mejoradas
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create, unless: :from_omniauth?,
            length: { minimum: 8 },
            format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*\z/, message: "debe incluir mayúscula, minúscula y número" }, allow_blank: true
  validate :avatar_validation

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

  private

  def avatar_validation
    return unless avatar.attached?

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, "excede 5MB")
    elsif !avatar.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:avatar, "debe ser JPEG, PNG o WebP")
    end
  end
end
