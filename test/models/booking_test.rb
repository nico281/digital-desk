require "test_helper"

class BookingTest < ActiveSupport::TestCase
  def setup
    @booking = build_valid_booking
  end

  # Validations

  test "booking válido con todos los atributos" do
    assert_valid @booking
  end

  test "requiere client" do
    @booking.client = nil
    assert_invalid @booking
  end

  test "requiere professional" do
    @booking.professional = nil
    assert_invalid @booking
  end

  test "requiere service" do
    @booking.service = nil
    assert_invalid @booking
  end

  test "requiere availability_block" do
    @booking.availability_block = nil
    assert_invalid @booking
  end

  test "client no puede ser el mismo que el professional" do
    @booking.client = @booking.professional.user
    assert_invalid @booking
  end

  test "status debe estar en lista válida" do
    assert_raises ArgumentError do
      @booking.status = "invalid"
    end
  end

  # Estados

  test "pending? es true para booking pendiente" do
    assert bookings(:pending_booking).pending?
  end

  test "confirmed? es true para booking confirmado" do
    assert bookings(:confirmed_booking).confirmed?
  end

  test "completed? es true para booking completado" do
    assert bookings(:completed_booking).completed?
  end

  test "cancelled? es true para booking cancelado" do
    assert bookings(:cancelled_booking).cancelled?
  end

  # Métodos de estado

  test "confirm! cambia status a confirmed" do
    @booking.status = :pending
    @booking.confirm!
    assert_equal "confirmed", @booking.status
  end

  test "cancel! cambia status a cancelled y libera bloque" do
    booking = create_booking(status: :confirmed)
    block = booking.availability_block
    block.update!(booking: booking)

    booking.cancel!

    assert_equal "cancelled", booking.status
    assert_equal "available", block.reload.status
    assert_nil block.reload.booking_id
  end

  test "complete! cambia status a completed" do
    @booking.status = :confirmed
    @booking.complete!
    assert_equal "completed", @booking.status
  end

  # Asociaciones

  test "booking pertenece a client" do
    assert_equal users(:client), @booking.client
  end

  test "booking pertenece a professional" do
    assert_equal professionals(:pro), @booking.professional
  end

  test "booking pertenece a service" do
    assert_equal services(:yoga_class), @booking.service
  end

  test "booking pertenece a availability_block" do
    assert_equal availability_blocks(:available_block), @booking.availability_block
  end

  test "booking puede tener review" do
    assert_equal reviews(:good_review).booking, bookings(:completed_booking)
  end

  test "booking confirmado tiene conversation" do
    booking = create_booking(status: :confirmed)
    assert booking.conversation.present?
  end

  # Scopes

  test "scope upcoming retorna solo bookings futuros" do
    skip "Revisar scope upcoming - usa join con availability_block"
    upcoming = Booking.upcoming
    assert_includes upcoming, bookings(:pending_booking)
    assert_includes upcoming, bookings(:confirmed_booking)
    refute_includes upcoming, bookings(:completed_booking)
  end

  test "scope pending retorna solo bookings pendientes" do
    pending = Booking.pending
    assert_includes pending, bookings(:pending_booking)
    refute_includes pending, bookings(:confirmed_booking)
  end

  test "scope confirmed retorna solo bookings confirmados" do
    confirmed = Booking.confirmed
    assert_includes confirmed, bookings(:confirmed_booking)
    refute_includes confirmed, bookings(:pending_booking)
  end
end
