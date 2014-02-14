class Api::V1::CategoriesController < Api::V1::BaseController
  def index
    @categories = Category.alphabetically

    if params[:parent_id].present?
      @categories = @categories.children_of(params[:parent_id])
    else
      @categories = @categories.roots
    end
  end
end
