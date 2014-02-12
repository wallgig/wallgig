class FavouritesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_owner

  layout false, except: [:index]

  def index
    @wallpapers = @owner.favourite_wallpapers
                        .accessible_by(current_ability, :read)
                        .page(params[:page])

    @wallpapers = @wallpapers.with_purities(current_purities) unless myself?

    @wallpapers = WallpapersFavouriteStatusPopulator.new(@wallpapers, current_user).wallpapers
    @wallpapers = WallpapersDecorator.new(@wallpapers)

    if request.xhr?
      render partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }
    else
      render layout: 'user_profile'
    end
  end

  private

  def set_owner
    if params[:user_id].present?
      @owner = @user = User.find_by_username!(params[:user_id])
      authorize! :read, @owner
    end
  end
end
