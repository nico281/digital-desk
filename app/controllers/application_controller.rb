class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user_role

  private

  def current_user_role
    current_user&.role
  end

  def require_authentication!
    redirect_to root_path, alert: "Debes iniciar sesión" unless user_signed_in?
  end

  def require_professional!
    redirect_to pro_setup_path, notice: "Completa tu perfil profesional" if current_user&.role != "professional"
  end
end
