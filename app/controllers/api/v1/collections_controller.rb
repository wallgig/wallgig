class Api::V1::CollectionsController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:create]
  before_action :set_user, only: [:index, :create]

  # GET /api/v1/users/:user_id/collections.json
  def index
    @collections = @user.collections.
      accessible_by(current_ability, :read)

    if params[:wallpaper_id].present?
      @wallpaper = Wallpaper.find(params[:wallpaper_id])
      authorize! :read, @wallpaper

      collections_wallpaper = CollectionsWallpaper.arel_table
      @collections = @collections.
        includes(:collections_wallpapers).
        where(collections_wallpaper[:wallpaper_id].eq(params[:wallpaper_id])).
        references(:collections_wallpapers)
    else
      @collections = @collections.ordered
    end
  end

  # POST /api/v1/users/:user_id/collections.json
  def create
    @collection = @user.collections.new(collection_params)
    authorize! :create, @collection

    if @collection.save
      render action: 'show', status: :created, location: @collection
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    if params[:user_id] == 'me'
      @user = current_user
    else
      @user = User.find_by_username!(params[:user_id])
    end
    authorize! :read, @user
  end

  def collection_params
    params.require(:collection).permit(:name, :public)
  end
end
