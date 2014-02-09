class TagsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_tag, only: [:show, :edit, :update]
  before_action :set_categories, only: [:new, :edit, :create, :update]

  def show
    @wallpapers = @tag.wallpapers.accessible_by(current_ability, :read)
                                 .with_purities(current_purities)
                                 .page(params[:page])

    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { user: current_user })

    if request.xhr?
      render partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }
    end
  end

  def new
    @tag = current_user.coined_tags.new
    authorize! :create, @tag
  end

  def edit
    authorize! :update, @tag
  end

  def create
    @tag = current_user.coined_tags.new(tag_params)
    authorize! :create, @tag

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

  def update
    authorize! :update, @tag

    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_tag
    @tag = Tag.friendly.find(params[:id])
    authorize! :read, @tag
  end

  def tag_params
    params.require(:tag).permit(:name, :category_id, :purity)
  end

  def set_categories
    @categories = Category.arrange_as_array(order: :name)
  end
end
