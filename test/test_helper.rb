ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  fixtures :all

  # Helper para sign in como user en model tests
  def sign_in(user)
    @current_user = user
  end

  # Helper para crear booking válido
  def build_valid_booking(overrides = {})
    defaults = {
      client: users(:client),
      professional: professionals(:pro),
      service: services(:yoga_class),
      availability_block: availability_blocks(:available_block),
      status: :pending
    }
    Booking.new(defaults.merge(overrides))
  end

  # Helper para crear booking y guardar
  def create_booking(overrides = {})
    booking = build_valid_booking(overrides)
    booking.save!
    booking
  end

  # Assert que el registro es válido
  def assert_valid(record)
    assert record.valid?, "Expected #{record.class.name} to be valid, but got errors: #{record.errors.full_messages.join(', ')}"
  end

  # Assert que el registro NO es válido
  def assert_invalid(record, expected_errors = nil)
    assert_not record.valid?, "Expected #{record.class.name} to be invalid"
    if expected_errors
      expected_errors.each do |error|
        assert_includes record.errors.full_messages, error
      end
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Login como user y seguir redirect
  def login_as(user)
    sign_in user
    user
  end

  # Login como cliente
  def login_as_client
    login_as users(:client)
  end

  # Login como profesional
  def login_as_pro
    login_as users(:pro_user)
  end

  # Assert respuesta exitosa
  def assert_success
    assert_response :success
  end

  # Assert redirect a login
  def assert_require_login
    assert_redirected_to new_user_session_path
  end
end
