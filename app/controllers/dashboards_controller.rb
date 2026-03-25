class DashboardsController < ApplicationController
  layout "dashboard"
  before_action :require_authentication!

  def show
    @user = current_user
    @professional = @user.professional

    @upcoming_bookings = Booking.where(client: @user)
      .where(status: [ :pending, :confirmed ])
      .joins(:availability_block)
      .where("availability_blocks.date >= ?", Date.current)
      .order("availability_blocks.date ASC, availability_blocks.start_time ASC")
      .includes({ professional: :user }, :service, :availability_block)

    @next_booking = @upcoming_bookings.where(status: :confirmed).first

    if @professional
      @pending_pro_bookings_count = Booking.where(professional: @professional)
        .where(status: :pending).count
      @pending_pro_bookings = Booking.where(professional: @professional)
        .where(status: :pending)
        .joins(:availability_block)
        .order("availability_blocks.date ASC, availability_blocks.start_time ASC")
        .includes(:client, :service, :availability_block)
        .limit(3)
      @pro_services_count = @professional.services.count
      @has_availability = @professional.availability_schedules.any?
    end
  end
end
