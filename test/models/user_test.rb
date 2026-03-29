require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:client)
  end

  # Validations

  test "user válido con todos los atributos" do
    assert_valid @user
  end

  test "requiere nombre" do
    @user.name = nil
    assert_invalid @user, ["Name no puede estar en blanco"]
  end

  test "requiere email" do
    @user.email = nil
    assert_invalid @user
  end

  test "email debe ser único" do
    duplicate = User.new(name: "Otro", email: @user.email, password: "Password123")
    assert_invalid duplicate
  end

  test "email debe ser válido" do
    @user.email = "invalid_email"
    assert_invalid @user
  end

  test "email es case insensitive" do
    duplicate = User.new(name: "Otro", email: @user.email.upcase, password: "Password123")
    assert_invalid duplicate
  end

  # Asociaciones

  test "client tiene conversaciones como cliente" do
    assert @user.conversations_as_client.include?(conversations(:pro_conversation))
  end

  test "client tiene reservas como cliente" do
    assert @user.bookings_as_client.any?
  end

  test "professional tiene perfil profesional" do
    pro_user = users(:pro_user)
    assert pro_user.professional.present?
  end

  test "client no tiene perfil profesional" do
    assert_nil @user.professional
  end

  # Roles

  test "role client es válido" do
    assert @user.client?
    assert_equal "client", @user.role
  end

  test "role professional es válido" do
    pro = users(:pro_user)
    assert pro.professional?
    assert_equal "professional", pro.role
  end

  # Avatar

  test "puede tener avatar adjunto" do
    skip "Requiere archivo de imagen"
    @user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/avatar.png")), filename: "avatar.png", content_type: "image/png")
    assert @user.avatar.attached?
  end
end
