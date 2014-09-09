class Api::V1::CollectionsController < Api::V1::BaseController
  before_action :set_user, only: [:index]

  # GET /api/v1/users/:user_id/collections
  def index
    if params[:wallpaper_id].present?
      @wallpaper = Wallpaper.find(params[:wallpaper_id])
      authorize! :read, @wallpaper

      collections_wallpaper = CollectionsWallpaper.arel_table
      @collections = @user.collections.
        includes(:collections_wallpapers).
        where(collections_wallpaper[:wallpaper_id].eq(params[:wallpaper_id])).
        references(:collections_wallpapers)
    else
      @collections = @user.collections.ordered
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
end
