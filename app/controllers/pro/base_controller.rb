module Pro
  class BaseController < ApplicationController
    layout "dashboard"
    before_action :require_authentication!
    before_action :set_professional

    private

    def set_professional
      @professional = current_user&.professional
    end

    def require_professional!
      redirect_to pro_setup_path, notice: "Completá tu perfil profesional primero" unless @professional
    end

    def require_setup_complete!
      return require_professional! unless @professional
      unless @professional.setup_complete?
        redirect_to pro_setup_path, notice: "Completá la configuración de tu perfil primero"
      end
    end
  end
end
