class Api::V1::TagsController < Api::V1::BaseController
  before_action :authenticate_user!

  def index
    if search_params[:q].blank?
      @tags = Tag.none
    else
      @tags = Tag.name_like(params[:q]).includes(:category).limit(20)
    end

    @tags = @tags.includes(:category)
    @tags = @tags.where.not(id: search_params[:exclude_ids]) if search_params[:exclude_ids].present?
  end

  def find_or_initialize
    @tag = Tag.find_by_name(params[:name]) if params[:name].present?
    @available_categories = Category.arrange_as_array(order: :name) if @tag.blank?
  end

  def create
    @tag = current_user.coined_tags.new(tag_params)
    authorize! :create, @tag

    if @tag.save
      render action: 'show', status: :created
    else
      render json: @tag.errors, status: :unprocessable_entity
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