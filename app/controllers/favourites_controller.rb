class FavouritesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_user
  layout 'user_profile'

  # GET /users/1/favourites
  # GET /users/1/favourites.json
  def index
    @wallpapers = @user.favourite_wallpapers
                       .accessible_by(current_ability, :read)
                       .page(params[:page])
    @wallpapers = @wallpapers.with_purities(current_purities) unless myself?

    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { current_user: current_user })

    respond_to do |format|
      format.html
      format.json do
        html = render_to_string partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }, formats: [:html]
        render json: { html: html }
      end
    end
  end

  private
    def set_user
      @user = User.find_by_username!(params[:user_id])
      authorize! :read, @user
    end
end
