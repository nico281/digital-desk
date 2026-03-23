module Pro
  class BookingsController < BaseController
    before_action :require_professional!

    def index
      @bookings = @professional.bookings
                    .includes(:client, :service, :availability_block)
                    .order(created_at: :desc)

      @filter = params[:status]
      @bookings = @bookings.where(status: @filter) if @filter.present? && Booking.statuses.key?(@filter)
    end
  end
end
