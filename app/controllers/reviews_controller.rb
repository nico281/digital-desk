class ReviewsController < ApplicationController
  before_action :require_authentication!
  before_action :set_booking

  def create
    @review = @booking.build_review(review_params)
    @review.client = current_user
    @review.professional = @booking.professional

    if @review.save
      redirect_to @booking, notice: "Reseña enviada"
    else
      redirect_to @booking, alert: @review.errors.full_messages.join(", ")
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
