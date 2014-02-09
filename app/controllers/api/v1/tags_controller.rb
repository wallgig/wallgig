class Api::V1::TagsController < Api::V1::BaseController
  def index
    if search_params[:q].blank?
      @tags = Tag.none
    else
      @tags = Tag.name_like(params[:q]).includes(:category).limit(20)
    end

    if search_params[:exclude_ids].present?
      @tags = @tags.where.not(id: search_params[:exclude_ids])
    end
  end

  private

  def search_params
    params.permit(:q, exclude_ids: [])
  end
end