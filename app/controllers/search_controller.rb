class SearchController < ApplicationController
  def index
    @professionals = search_professionals.page(params[:page]).per(12)
    @categories = Category.root
  end

  private

  def search_professionals
    scope = Professional.joins(:user, services: :category)
      .includes(:user, :categories, services: :category)
      .where(services: { active: true })

    scope = scope.where(services: { category_id: params[:category_id] }) if params[:category_id].present?
    scope = scope.where("LOWER(users.name) LIKE ?", "%#{params[:q]}%") if params[:q].present?
    scope = scope.where("services.price <= ?", params[:max_price].to_i) if params[:max_price].present?

    scope = case params[:sort]
    when "rating" then scope.order(rating_avg: :desc)
    when "price_asc" then scope.order("services.price ASC")
    when "price_desc" then scope.order("services.price DESC")
    else scope.order(rating_avg: :desc)
    end

    scope.distinct
  end
end
