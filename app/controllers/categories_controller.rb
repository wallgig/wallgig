class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def index
    @categories = Category.roots.alphabetically
    @tags = Tag.includes(:category)
               .not_empty
               .with_purities(current_purities)
               .order(wallpapers_count: :desc)
               .page(params[:page])
  end

  def show
    @ancestors = @category.ancestors
    @categories = @category.children.alphabetically
    @tags = Tag.includes(:category)
               .in_category(@category)
               .not_empty
               .with_purities(current_purities)
               .order(wallpapers_count: :desc)
               .page(params[:page])

    render action: 'index'
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end
end
