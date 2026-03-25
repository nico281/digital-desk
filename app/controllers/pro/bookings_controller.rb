module Pro
  class BookingsController < BaseController
    before_action :require_professional!
    before_action :set_booking, only: [ :confirm, :reject ]

    def index
      @bookings = @professional.bookings
                    .includes(:client, :service, :availability_block)
                    .order(created_at: :desc)

      @filter = params[:status]
      @bookings = @bookings.where(status: @filter) if @filter.present? && Booking.statuses.key?(@filter)
    end

    def confirm
      @booking.confirm!
      @booking.update!(meeting_room_id: "booking_#{@booking.id}")
      BookingMailer.booking_confirmed(@booking).deliver_later

      redirect_to pro_bookings_path, notice: "Reserva confirmada"
    end

    def reject
      @booking.cancel!
      BookingMailer.booking_rejected(@booking).deliver_later

      redirect_to pro_bookings_path, notice: "Reserva rechazada"
    end

    private

    def set_booking
      @booking = @professional.bookings.pending.find(params[:id])
    end
  end
end
