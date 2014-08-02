class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  helper_method :search_params

  def index
    @categories = policy_scope(Category).
      roots.
      alphabetically

    @tags = tag_collection_scope
    @tags = @tags.search_names(params[:q]) if params[:q].present?
  end

  def show
    authorize @category

    @ancestors = @category.ancestors
    @categories = @category.children.alphabetically
    @tags = tag_collection_scope.in_category_and_subtree(@category)

    respond_to do |format|
      format.html { render action: :index }
    end
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  # TODO refactor
  def search_params
    params.permit(:q, purity: []).tap do |p|
      p[:purity] = Array.wrap(p[:purity]).select { |p| ['sfw', 'sketchy', 'nsfw'].include?(p) }.presence
    end
  end

  def tag_collection_scope
    policy_scope(Tag).
      includes(:category).
      with_purities(current_purities).
      most_wallpapers_first(current_purities).
      page(params[:page])
  end
end
