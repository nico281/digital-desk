require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  def setup
    @service = services(:yoga_class)
  end

  # Validations

  test "service válido con todos los atributos" do
    assert_valid @service
  end

  test "requiere title" do
    @service.title = nil
    assert_invalid @service
  end

  test "requiere professional" do
    @service.professional = nil
    assert_invalid @service
  end

  test "requiere price" do
    @service.price = nil
    assert_invalid @service
  end

  test "price debe ser mayor a 0" do
    @service.price = 0
    assert_invalid @service
  end

  test "price debe ser menor a 100000" do
    @service.price = 1000000
    # Validación no existe aún - marcar como skip
    skip "Agregar validación de máximo precio"
  end

  test "requiere duration_minutes" do
    @service.duration_minutes = nil
    assert_invalid @service
  end

  test "duration_minutes debe ser mayor a 0" do
    @service.duration_minutes = 0
    assert_invalid @service
  end

  test "duration_minutes debe ser menor a 480 minutos (8 horas)" do
    @service.duration_minutes = 500
    assert_invalid @service
  end

  test "description es opcional" do
    @service.description = nil
    assert_valid @service
  end

  test "category es opcional" do
    @service.category = nil
    assert_valid @service
  end

  # Asociaciones

  test "service pertenece a professional" do
    assert_equal professionals(:pro), @service.professional
  end

  test "service pertenece a category" do
    assert_equal categories(:yoga), @service.category
  end

  # Scopes

  test "scope active retorna solo servicios activos" do
    active = Service.active
    assert_includes active, @service
  end

  test "scope by_category retorna servicios de esa categoría" do
    services = Service.by_category(categories(:yoga))
    assert_includes services, @service
  end

  # Métodos

  test "duration_in_hours retorna duración en horas" do
    skip "Método no existe aún"
    @service.duration_minutes = 60
    assert_equal 1.0, @service.duration_in_hours
  end

  test "formatted_price retorna precio formateado" do
    skip "Método no existe aún"
    @service.price = 5000
    assert_equal "$5.000", @service.formatted_price
  end
end
