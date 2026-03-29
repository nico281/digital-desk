# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  private

  def require_authentication!
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      respond_to do |format|
        format.html { redirect_to new_user_session_path, alert: "Debes iniciar sesión" }
        format.json { render json: { error: "Authentication required" }, status: :unauthorized }
        format.turbo_stream { render status: :unauthorized }
      end
    end
  end

  def require_professional!
    require_authentication!
    return if current_user.professional?

    respond_to do |format|
      format.html { redirect_to pro_setup_path, notice: "Completa tu perfil profesional" }
      format.json { render json: { error: "Professional profile required" }, status: :forbidden }
      format.turbo_stream { render status: :forbidden }
    end
  end

  def require_verified_professional!
    require_professional!
    return if current_user.professional&.verified?

    respond_to do |format|
      format.html { redirect_to dashboard_path, alert: "Tu perfil debe estar verificado" }
      format.json { render json: { error: "Profile must be verified" }, status: :forbidden }
      format.turbo_stream { render status: :forbidden }
    end
  end

  def require_client!
    require_authentication!
    return if current_user.client?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "Acceso restringido a clientes" }
      format.json { render json: { error: "Client access only" }, status: :forbidden }
      format.turbo_stream { render status: :forbidden }
    end
  end

  def can_modify_booking?(booking)
    return false unless booking
    current_user.id == booking.client_id || current_user.professional&.id == booking.professional_id
  end

  def is_booking_client?(booking)
    return false unless booking
    current_user.id == booking.client_id
  end

  def is_booking_professional?(booking)
    return false unless booking
    current_user.professional&.id == booking.professional_id
  end
end
