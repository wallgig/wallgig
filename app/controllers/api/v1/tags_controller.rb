class Api::V1::TagsController < Api::V1::BaseController
  def index
    if search_params[:q].blank?
      @tags = Tag.none
    else
      @tags = Tag.name_like(params[:q]).includes(:category).limit(20)
    end

    @tags = @tags.includes(:category)
    @tags = @tags.where.not(id: search_params[:exclude_ids]) if search_params[:exclude_ids].present?
  end

  def find
    @tag = Tag.find_by_name(params[:name]) if params[:name].present?
  end

  private

  def search_params
    params.permit(:q, exclude_ids: [])
  end
end