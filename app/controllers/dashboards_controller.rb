class DashboardsController < ApplicationController
  before_action :require_authentication!

  def show
    @user = current_user

    if @user.professional
      @professional = @user.professional
      @upcoming_bookings_as_pro = Booking.where(professional: @professional)
        .where(status: [ :pending, :confirmed ])
        .order(:created_at)
        .includes(:client, :service)
    end

    @upcoming_bookings = Booking.where(client: @user)
      .where(status: [ :pending, :confirmed ])
      .order(:created_at)
      .includes({ professional: :user }, :service)
  end
end
