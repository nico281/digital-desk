class PagesController < ApplicationController
  def home
    @featured_categories = Category.where(parent_id: nil).limit(6)
    @featured_professionals = Professional.joins(:user)
      .includes(:categories, :services, user: :professional)
      .where(verified: true)
      .order(rating_avg: :desc)
      .limit(8)
  end
end
