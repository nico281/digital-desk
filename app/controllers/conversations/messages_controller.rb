module Conversations
  class MessagesController < ApplicationController
    before_action :require_authentication!
    before_action :set_conversation

    def create
      @message = @conversation.messages.build(message_params)
      @message.sender = current_user

      if @message.save
        @conversation.touch
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to conversation_path(@conversation) }
        end
      else
        redirect_to conversation_path(@conversation), alert: @message.errors.full_messages.join(", ")
      end
    end

    def mark_read
      ChatReadMarker.upsert(
        { user_id: current_user.id, conversation_id: @conversation.id, last_read_at: Time.current, created_at: Time.current, updated_at: Time.current },
        unique_by: [ :user_id, :conversation_id ]
      )
      head :no_content
    end

    private

    def set_conversation
      @conversation = Conversation.find(params[:conversation_id] || params[:id])
      unless @conversation.participant?(current_user)
        redirect_to root_path, alert: "No autorizado"
      end
    end

    def message_params
      params.require(:message).permit(:body, files: [])
    end
  end
end
