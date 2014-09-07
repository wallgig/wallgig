class Api::V1::WallpapersController < Api::V1::BaseController
  WALLPAPER_SEARCH_CACHE_TTL = 10.minutes

  before_action :authenticate_user_from_token!, only: [:create]
  before_action :set_wallpaper, only: [:show]

  include WallpaperSearchParams

  def index
    @wallpapers = WallpapersDecorator.new(
      wallpaper_search_results(search_options, compact_search_options),
      context: {
        search_options: search_options,
        current_user: current_user
      }
    )
  end

  def show
    @wallpaper = @wallpaper.decorate
    respond_with @wallpaper
  end

  def create
    @wallpaper = current_user.wallpapers.new(create_wallpaper_params)
    authorize! :create, @wallpaper

    respond_with @wallpaper do |format|
      if @wallpaper.save
        format.json do
          @wallpaper = @wallpaper.decorate
          render action: 'show', status: :created, location: @wallpaper
        end
      else
        format.json { render_json_error(@wallpaper, status: :unprocessable_entity)  }
      end
    end
  end

  private

  def set_wallpaper
    @wallpaper = Wallpaper.find(params[:id])
    authorize! :read, @wallpaper
  end

  def wallpaper_params
    params.require(:wallpaper).permit(:purity, :image, :image_url, :tag_list, :image_gravity, :source)
  end

  def create_wallpaper_params
    params.permit(:purity, :image, :image_url, :tag_list, :image_gravity, :source)
  end

  def wallpaper_search_results(params, cache_params)
    Rails.cache.fetch([:wallpaper_search, cache_params], expires_in: WALLPAPER_SEARCH_CACHE_TTL) do
      wallpapers = WallpaperSearchService.new(params).execute
    end
  rescue TypeError
    logger.warn "Cannot cache wallpaper search results with params #{params}"
    Wallpaper.none
  end
end
