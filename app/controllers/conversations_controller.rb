class ConversationsController < ApplicationController
  layout "dashboard"
  before_action :require_authentication!

  def index
    @conversations = Conversation.for_user(current_user)
      .with_messages
      .includes(:client, :bookings, :chat_read_markers, professional: :user, messages: :sender)
      .order(updated_at: :desc)

    @last_messages = @conversations.to_h do |c|
      [ c.id, c.messages.max_by(&:created_at) ]
    end

    @unread_counts = Conversation.unread_counts_batch(@conversations, current_user)
    @booking_counts = Booking.where(conversation_id: @conversations.map(&:id))
      .group(:conversation_id).count
  end

  def show
    @conversation = Conversation.find(params[:id])
    unless @conversation.participant?(current_user)
      redirect_to root_path, alert: "No autorizado"
    end
  end
end
