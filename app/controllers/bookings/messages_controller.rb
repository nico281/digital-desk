module Bookings
  class MessagesController < ApplicationController
    before_action :require_authentication!
    before_action :set_booking

    def create
      @conversation = @booking.conversation
      @message = @conversation.messages.build(message_params)
      @message.sender = current_user
      @message.booking = @booking

      if @message.save
        @conversation.touch
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to booking_path(@booking, anchor: "chat") }
        end
      else
        redirect_to booking_path(@booking, anchor: "chat"), alert: @message.errors.full_messages.join(", ")
      end
    end

    def mark_read
      ChatReadMarker.upsert(
        { user_id: current_user.id, conversation_id: @booking.conversation_id, last_read_at: Time.current, created_at: Time.current, updated_at: Time.current },
        unique_by: [ :user_id, :conversation_id ]
      )
      head :no_content
    end

    private

    def set_booking
      @booking = Booking.find(params[:booking_id] || params[:id])
      redirect_to root_path, alert: "No autorizado" unless @booking.chat_participant?(current_user)
    end

    def message_params
      params.require(:message).permit(:body, files: [])
    end
  end
end
