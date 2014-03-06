class FavouritesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_user

  def index
    @wallpapers = @user.favourite_wallpapers
                       .accessible_by(current_ability, :read)
                       .page(params[:page])
    @wallpapers = @wallpapers.with_purities(current_purities) unless myself?

    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { current_user: current_user })

    if request.xhr?
      render partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }
    else
      render layout: 'user_profile'
    end
  end

  private

  def set_user
    @user = User.find_by_username!(params[:user_id])
    authorize! :read, @user
  end
end
