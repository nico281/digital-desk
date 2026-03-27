class Conversation < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :professional

  has_many :messages, dependent: :destroy
  has_many :chat_read_markers, dependent: :destroy
  has_many :bookings

  validates :client_id, uniqueness: { scope: :professional_id }
  validate :client_is_not_professional

  scope :for_user, ->(user) {
    left_joins(:professional)
      .where("conversations.client_id = :uid OR professionals.user_id = :uid", uid: user.id)
  }

  scope :with_messages, -> {
    where(id: Message.select(:conversation_id))
  }

  def participant?(user)
    client_id == user.id || professional.user_id == user.id
  end

  def other_user(user)
    client_id == user.id ? professional.user : client
  end

  def last_message
    messages.ordered.last
  end

  def unread_messages_count_for(user)
    marker = chat_read_markers.find_by(user: user)
    if marker
      messages.where("created_at > ?", marker.last_read_at).count
    else
      messages.count
    end
  end

  def self.find_or_start(client:, professional:)
    find_or_create_by!(client: client, professional: professional)
  end

  private

  def client_is_not_professional
    return if client.nil? || professional.nil?
    errors.add(:client, "no puede chatear consigo mismo") if client.id == professional.user_id
  end
end
