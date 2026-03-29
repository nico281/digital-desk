# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  # before_action para acciones que modifican recursos
  included do
    before_action :verify_ownership!, only: [ :edit, :update, :destroy ]
  end

  private

  def verify_ownership!
    return if owner?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "No autorizado" }
      format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      format.turbo_stream { render status: :forbidden }
    end
  end

  def owner?
    return false unless resource
    return false unless current_user

    case resource
    when Professional
      current_user.id == resource.user_id
    when Booking
      current_user.id == resource.client_id || current_user.professional&.id == resource.professional_id
    when Conversation, Message, Review
      current_user.id == resource.client_id || current_user.professional&.id == resource.professional_id
    when Service, AvailabilitySchedule, AvailabilityBlock
      current_user.professional&.id == resource.professional_id
    else
      false
    end
  end

  def resource
    instance_variable_get("@#{resource_name}")
  end

  def resource_name
    controller_name.singularize
  end
end
