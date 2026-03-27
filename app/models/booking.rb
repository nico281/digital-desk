class Booking < ApplicationRecord
  enum :status, pending: 0, confirmed: 1, completed: 2, cancelled: 3

  belongs_to :client, class_name: "User"
  belongs_to :professional
  belongs_to :service
  belongs_to :availability_block
  belongs_to :payment, optional: true
  belongs_to :conversation, optional: true
  has_one :review
  has_many :messages
  has_many :chat_read_markers

  validates :client, presence: true
  validates :professional, presence: true
  validates :service, presence: true
  validates :availability_block, presence: true
  validate :client_is_not_professional

  scope :upcoming, -> { where("availability_block.date >= ?", Date.today) }
  scope :past, -> { where("availability_block.date < ?", Date.today) }
  scope :for_professional, ->(professional_id) { where(professional_id:) }
  scope :for_client, ->(client_id) { where(client_id:) }

  def confirm!
    update!(status: :confirmed)
  end

  def complete!
    update!(status: :completed)
  end

  def cancel!
    transaction do
      update!(status: :cancelled)
      availability_block.release!
    end
  end

  def start_time
    availability_block&.start_time
  end

  def end_time
    availability_block&.end_time
  end

  def date
    availability_block&.date
  end

  def unread_messages_count_for(user)
    conversation&.unread_messages_count_for(user) || 0
  end

  def chat_participant?(user)
    conversation&.participant?(user) || client_id == user.id || professional.user_id == user.id
  end

  before_create :ensure_conversation

  private

  def ensure_conversation
    self.conversation ||= Conversation.find_or_start(client: client, professional: professional)
  end

  def client_is_not_professional
    return if client.nil? || professional.nil?
    if client.id == professional.user_id
      errors.add(:client, "cannot book their own service")
    end
  end
end
