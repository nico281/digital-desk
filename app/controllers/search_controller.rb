class SearchController < ApplicationController
  def index
    @categories = Category.root.ordered
    @selected_category = Category.find_by(slug: params[:category]) if params[:category].present?
    @subcategories = @selected_category&.children&.ordered || []

    @professionals = search_professionals
  end

  private

  def search_professionals
    scope = Professional.joins(:user)
      .includes(:user, :categories, :services)
      .distinct

    # Category filter (includes subcategories)
    if @selected_category
      category_ids = [ @selected_category.id ] + @selected_category.children.pluck(:id)
      scope = scope.joins(services: :category)
        .where(services: { category_id: category_ids })
    end

    # Subcategory filter
    if params[:subcategory].present?
      sub = Category.find_by(slug: params[:subcategory])
      scope = scope.joins(services: :category).where(services: { category_id: sub.id }) if sub
    end

    # Text search
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      scope = scope.where("LOWER(users.name) LIKE ? OR LOWER(professionals.headline) LIKE ?", q, q)
    end

    # Price filter
    if params[:max_price].present?
      scope = scope.joins(:services).where("services.price <= ?", params[:max_price].to_i)
    end

    # Sort
    scope = case params[:sort]
    when "price_asc" then scope.joins(:services).order("services.price ASC")
    when "price_desc" then scope.joins(:services).order("services.price DESC")
    when "newest" then scope.order(created_at: :desc)
    else scope.order(rating_avg: :desc)
    end

    scope
  end
end
