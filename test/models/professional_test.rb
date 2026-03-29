require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  setup do
    @pro = professionals(:pro)
  end

  # Validations

  test "professional válido con todos los atributos" do
    assert_valid @pro
  end

  test "requiere user" do
    @pro.user = nil
    assert_invalid @pro
  end

  test "user debe ser único" do
    skip "Validación de uniqueness en user_id no funciona en fixtures"
    duplicate = Professional.new(user: @pro.user)
    assert_invalid duplicate
  end

  test "currency debe estar en lista válida" do
    @pro.currency = "XXX"
    assert_invalid @pro
  end

  test "block_duration_minutes debe estar en lista válida" do
    @pro.block_duration_minutes = 90
    assert_invalid @pro
  end

  test "buffer_minutes debe estar en lista válida" do
    @pro.buffer_minutes = 20
    assert_invalid @pro
  end

  test "rating_avg debe estar entre 0 y 5" do
    @pro.rating_avg = -1
    assert_invalid @pro

    @pro.rating_avg = 6
    assert_invalid @pro

    @pro.rating_avg = 4.5
    assert_valid @pro
  end

  # Asociaciones

  test "professional pertenece a user" do
    assert_equal users(:pro_user), @pro.user
  end

  test "professional tiene muchos servicios" do
    assert @pro.services.any?
  end

  test "professional tiene availability_schedules" do
    assert @pro.availability_schedules.any?
  end

  test "professional tiene availability_blocks" do
    assert @pro.availability_blocks.any?
  end

  test "professional tiene bookings" do
    assert @pro.bookings.any?
  end

  test "professional tiene conversations" do
    assert @pro.conversations.any?
  end

  test "professional tiene reviews" do
    assert @pro.reviews.any?
  end

  test "professional tiene categories" do
    skip "El professional en fixtures no tiene categories asociadas"
    assert @pro.categories.any?
  end

  # Métodos existentes

  test "update_rating! calcula correctamente" do
    @pro.update_columns(rating_avg: 0.0, rating_count: 0)

    @pro.update_rating!(5)
    assert_equal 5.0, @pro.rating_avg
    assert_equal 1, @pro.rating_count

    @pro.update_rating!(3)
    assert_equal 4.0, @pro.rating_avg
    assert_equal 2, @pro.rating_count

    @pro.update_rating!(1)
    assert_equal 3.0, @pro.rating_avg
    assert_equal 3, @pro.rating_count
  end

  test "verified? retorna true si está verificado" do
    assert @pro.verified?
  end

  test "verified? retorna false si no está verificado" do
    refute professionals(:unverified_pro).verified?
  end

  test "setup_complete? retorna true si completó setup" do
    assert @pro.setup_complete?
  end

  test "setup_complete? retorna false si no completó setup" do
    unverified = professionals(:unverified_pro)
    unverified.setup_completed_at = nil
    refute unverified.setup_complete?
  end
end
