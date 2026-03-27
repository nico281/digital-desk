class ConversationsController < ApplicationController
  layout "dashboard"
  before_action :require_authentication!

  def index
    @conversations = Conversation.for_user(current_user)
      .with_messages
      .includes(:client, professional: :user)
      .order(updated_at: :desc)
  end

  def show
    @conversation = Conversation.find(params[:id])
    unless @conversation.participant?(current_user)
      redirect_to root_path, alert: "No autorizado"
    end
  end
end
