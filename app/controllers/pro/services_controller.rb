module Pro
  class ServicesController < BaseController
    before_action :require_setup_complete!
    before_action :set_service, only: [ :edit, :update, :destroy ]

    # Autorización: solo el dueño puede modificar sus servicios
    include Authorizable

    def index
      @services = @professional.services.includes(:category).order(created_at: :desc)
    end

    def new
      @service = @professional.services.build
      @categories = Category.ordered
    end

    def create
      @service = @professional.services.build(service_params)

      if @service.save
        redirect_to pro_services_path, notice: "Servicio creado"
      else
        @categories = Category.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.ordered
    end

    def update
      if @service.update(service_params)
        redirect_to pro_services_path, notice: "Servicio actualizado"
      else
        @categories = Category.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @service.destroy
      redirect_to pro_services_path, notice: "Servicio eliminado"
    end

    private

    def set_service
      @service = @professional.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:title, :description, :price, :duration_minutes, :category_id)
    end
  end
end
