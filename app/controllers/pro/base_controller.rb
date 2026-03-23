module Pro
  class BaseController < ApplicationController
    before_action :require_authentication!
    before_action :set_professional, except: [ :setup_redirect ]

    private

    def set_professional
      @professional = current_user.professional
    end

    def require_professional!
      redirect_to pro_setup_path, notice: "Completá tu perfil profesional primero" unless @professional
    end
  end
end
