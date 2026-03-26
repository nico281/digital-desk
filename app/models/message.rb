class Message < ApplicationRecord
  belongs_to :booking
  belongs_to :sender, class_name: "User"
  has_many_attached :files

  scope :ordered, -> { order(created_at: :asc) }

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp application/pdf].freeze
  MAX_FILE_SIZE = 10.megabytes

  validate :body_or_files_present
  validate :acceptable_files

  after_create_commit :broadcast_message

  def other_participant
    booking.client_id == sender_id ? booking.professional.user : booking.client
  end

  private

  def broadcast_message
    [ booking.client, booking.professional.user ].each do |user|
      broadcast_append_to(
        "booking_#{booking_id}_user_#{user.id}_messages",
        target: "messages_booking_#{booking_id}",
        partial: "bookings/messages/message",
        locals: { message: self, current_user: user }
      )
    end
  end

  def body_or_files_present
    errors.add(:base, "Escribí un mensaje o adjuntá un archivo") unless body.present? || files.attached?
  end

  def acceptable_files
    return unless files.attached?
    files.each do |file|
      unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
        errors.add(:files, "tipo no permitido: #{file.filename}")
      end
      if file.byte_size > MAX_FILE_SIZE
        errors.add(:files, "#{file.filename} excede 10MB")
      end
    end
  end
end
