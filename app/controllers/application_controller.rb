class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :resolve_layout

  helper_method :current_user_role

  private

  def resolve_layout
    if devise_controller? && !user_signed_in?
      "devise"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def current_user_role
    current_user&.role
  end

  def require_authentication!
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      redirect_to new_user_session_path, alert: "Debes iniciar sesión"
    end
  end

  def require_professional!
    redirect_to pro_setup_path, notice: "Completa tu perfil profesional" if current_user&.role != "professional"
  end

  def after_sign_in_path_for(resource)
    if session[:pending_booking].present?
      complete_pending_bookings_path
    else
      stored_location_for(resource) || dashboard_path
    end
  end
end
