class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def index
    @categories = Category.roots.alphabetically

    @tags = Tag.includes(:category)
               .with_purities(current_purities)
               .most_wallpapers_first(current_purities)
               .page(params[:page])
  end

  def show
    @ancestors = @category.ancestors

    @categories = @category.children.alphabetically

    @tags = Tag.includes(:category)
               .in_category_and_subtree(@category)
               .with_purities(current_purities)
               .most_wallpapers_first(current_purities)
               .page(params[:page])

    render action: 'index'
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end
end
