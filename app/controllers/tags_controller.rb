class TagsController < ApplicationController
  before_action :set_tag, only: [:show]

  def index
    q = Tag.ransack(search_params)
    @tags = policy_scope(q.result).
      includes(:category).
      page(params[:page])

    respond_to do |format|
      format.json
    end
  end

  def show
    authorize @tag

    @wallpapers = policy_scope(@tag.wallpapers).
      with_purities(current_purities).
      latest.
      limit(current_settings.per_page)
    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { current_user: current_user })

    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @tag = current_user.coined_tags.new(tag_params)
    authorize @tag

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tag }
      else
        format.html { render action: 'new' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # def update
  #   authorize! :update, @tag
  #
  #   respond_to do |format|
  #     if @tag.update(tag_params)
  #       format.html { redirect_to @tag, notice: 'Topic was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @tag.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

  def search_params
    params.permit(:name_cont, :name_matches, id_not_in: [])
  end

  def set_tag
    @tag = Tag.friendly.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :category_id, :purity)
  end
end
