class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show ]

  def index
    @categories = Category.root.includes(:children)
  end

  def show
    @subcategories = @category.children
    @professionals = Professional.joins(:services, services: :category)
      .includes(:user, :categories)
      .where(services: { category_id: [ @category.id ] + @category.children.pluck(:id) })
      .where(verified: true)
      .distinct
      .order(rating_avg: :desc)
      .page(params[:page])
      .per(12)
  end

  private

  def set_category
    @category = Category.find_by!(slug: params[:id])
  end
end
