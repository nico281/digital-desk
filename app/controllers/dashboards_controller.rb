class DashboardsController < ApplicationController
  layout "dashboard"
  before_action :require_authentication!

  def show
    @user = current_user

    @professional = @user.professional

    @upcoming_bookings = Booking.where(client: @user)
      .where(status: [ :pending, :confirmed ])
      .order(:created_at)
      .includes({ professional: :user }, :service)
  end
end
