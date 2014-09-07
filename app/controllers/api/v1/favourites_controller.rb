class Api::V1::FavouritesController < Api::V1::BaseController
  before_action :ensure_from_mashape!
  before_action :set_user, only: [:index]

  def index
    @wallpapers = @user.favourite_wallpapers.page(params[:page]).decorate
    respond_with @wallpapers do |format|
      format.json { render template: 'api/v1/wallpapers/index' }
    end
  end

  # PATCH /api/v1/wallpapers/:wallpaper_id/favourite/toggle
  def toggle
    @wallpaper = Wallpaper.find(params[:wallpaper_id])
    authorize! :read, @wallpaper

    if current_user.favourited?(@wallpaper)
      current_user.unfavourite(@wallpaper)
      @wallpaper.favourites_count -= 1
      @favourited = false
    else
      current_user.favourite(@wallpaper)
      @wallpaper.favourites_count += 1
      @favourited = true
    end
  end

  private

  def set_user
    @user = User.find_by_username!(params[:user_id])
    authorize! :read, @user
  end
end
