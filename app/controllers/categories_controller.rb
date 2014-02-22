class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  helper_method :search_params

  def index
    @categories = Category.roots.alphabetically

    if params[:q].present?
      @tags = tag_collection_scope.search_names(params[:q])
    else
      @tags = tag_collection_scope
    end
  end

  def show
    @ancestors = @category.ancestors

    @categories = @category.children.alphabetically

    @tags = tag_collection_scope.in_category_and_subtree(@category)

    render action: 'index'
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def search_params
    params.permit(:q, purity: []).tap do |p|
      p[:purity] = Array.wrap(p[:purity]).select { |p| ['sfw', 'sketchy', 'nsfw'].include?(p) }.presence
    end
  end

  def current_purities
    search_params[:purity] || super
  end

  def tag_collection_scope
    Tag.includes(:category)
       .with_purities(current_purities)
       .most_wallpapers_first(current_purities)
       .page(params[:page])
  end
end
