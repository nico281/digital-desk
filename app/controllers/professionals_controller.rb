class ProfessionalsController < ApplicationController
  before_action :set_professional, only: [ :show ]

  def index
    @professionals = Professional.joins(:user)
      .includes(:categories, :services, :cancellation_policy)
      .where(verified: true)
      .order(rating_avg: :desc)
      .page(params[:page])
      .per(12)

    @categories = Category.where(parent_id: nil)
  end

  def show
    @services = @professional.services.active
    @reviews = @professional.reviews.order(created_at: :desc).limit(5)
  end

  private

  def set_professional
    @professional = Professional.find(params[:id])
  end
end
