class Api::V1::TagsController < Api::V1::BaseController
  before_action :authenticate_user!

  def create
    @tag = current_user.coined_tags.new(tag_params)
    authorize! :create, @tag

    if @tag.save
      render action: 'show', status: :created
    else
      render json: @tag.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def search_params
    params.permit(:q, exclude_ids: [])
  end

  def tag_params
    params.require(:tag).permit(:name, :purity, :category_id)
  end
end