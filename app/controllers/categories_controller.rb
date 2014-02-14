class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def index
    @categories = Category.roots.alphabetically
    @tags       = Tag.not_empty.order(wallpapers_count: :desc).page(params[:page])
  end

  def show
    @ancestors  = @category.ancestors
    @categories = @category.children.alphabetically
    @tags       = Tag.in_category(@category).not_empty.order(wallpapers_count: :desc).page(params[:page])

    render action: 'index'
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end
end
