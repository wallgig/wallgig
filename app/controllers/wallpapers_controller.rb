class WallpapersController < ApplicationController
  WALLPAPER_SEARCH_CACHE_TTL = 10.minutes

  before_action :authenticate_user!, except: [:index, :show, :set_profile_cover, :toggle_favourite, :collections, :toggle_collect]
  before_action :set_user, only: [:index]
  before_action :set_wallpaper, only: [:show, :edit, :update, :destroy, :update_purity, :history, :set_profile_cover, :toggle_favourite, :collections, :toggle_collect]
  before_action :record_wallpaper_impression, only: :show

  include WallpaperSearchParams

  layout :resolve_layout

  # GET /wallpapers
  def index
    @wallpapers = WallpapersDecorator.new(
      wallpaper_search_results(search_options, compact_search_options),
      context: {
        search_options: search_options,
        current_user: current_user
      }
    )

    @wallpaper_data = render_to_string(template: 'api/v1/wallpapers/index', formats: [:json], locals: { wallpapers: @wallpapers })

    respond_to do |format|
      format.html
    end
  end

  # GET /wallpapers/1
  # GET /wallpapers/1.json
  def show
    # Checks if requested screen resolution is present and valid
    # before telling @wallpaper to resize.
    if resize_params.present?
      screen_resolution = ScreenResolution.find_by_dimensions(resize_params[:width], resize_params[:height])
      unless @wallpaper.resize_image_to(screen_resolution)
        redirect_to @wallpaper, status: :moved_permanently, alert: 'Requested screen resolution is invalid.'
      end
    end

    @latest_comments = @wallpaper.comments.includes(:user).latest
    @wallpaper = @wallpaper.decorate
  end

  # GET /wallpapers/new
  def new
    @wallpaper = current_user.wallpapers.new
    authorize! :create, @wallpaper
  end

  # GET /wallpapers/1/edit
  def edit
    authorize! :update, @wallpaper
    @wallpaper = @wallpaper.decorate
  end

  # POST /wallpapers
  # POST /wallpapers.json
  def create
    @wallpaper = current_user.wallpapers.new_with_editing_user(create_wallpaper_params, current_user)
    authorize! :create, @wallpaper

    respond_to do |format|
      if @wallpaper.save
        format.html do
          if @wallpaper.approved?
            redirect_to @wallpaper, notice: 'Wallpaper was successfully created.'
          else
            redirect_to new_wallpaper_url, notice: 'Wallpaper was successfully submitted for moderator approval.'
          end
        end
        format.json { render action: 'show', status: :created, location: @wallpaper }
      else
        format.html { render action: 'new' }
        format.json { render json: @wallpaper.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wallpapers/1
  # PATCH/PUT /wallpapers/1.json
  def update
    @wallpaper.editing_user = current_user
    authorize! :update, @wallpaper

    respond_to do |format|
      if @wallpaper.update(update_wallpaper_params)
        format.html { redirect_to @wallpaper, notice: 'Wallpaper was successfully updated.' }
        format.json { head :no_content }
      else
        format.html do
          @wallpaper = @wallpaper.decorate
          render action: 'edit'
        end
        format.json { render json: @wallpaper.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallpapers/1
  # DELETE /wallpapers/1.json
  def destroy
    authorize! :destroy, @wallpaper
    @wallpaper.destroy

    respond_to do |format|
      format.html { redirect_to wallpapers_url }
      format.json { head :no_content }
    end
  end

  # PATCH /wallpapers/1/update_purity
  # PATCH /wallpapers/1/update_purity.js
  def update_purity
    authorize! :update_purity, @wallpaper
    @wallpaper.purity = params[:purity]
    @wallpaper.save!

    respond_to do |format|
      format.html { redirect_to @wallpaper, notice: 'Wallpaper purity was successfully updated.' }
      format.json
    end
  end

  # GET /wallpapers/1/history
  def history
  end

  # POST /wallpapers/save_search_params
  # POST /wallpapers/save_search_params.json
  def save_search_params
    session[:search_params] = search_params(false).except(:page).to_hash

    respond_to do |format|
      format.html { redirect_to :back, notice: 'Search settings successfully saved.' }
      format.json { head :no_content }
    end
  end

  def set_profile_cover
    if @wallpaper.sfw?
      current_profile.cover_wallpaper = @wallpaper
      current_profile.save!
      redirect_to current_user, notice: 'Profile cover was successfully changed.'
    else
      redirect_to current_user, alert: 'Only SFW wallpapers can be set as profile cover.'
    end
  end

  # TODO deprecate
  def toggle_favourite
    if current_user.favourited?(@wallpaper)
      current_user.unfavourite(@wallpaper)
      @fav_status = false
    else
      current_user.favourite(@wallpaper)
      @fav_status = true
    end

    respond_to do |format|
      format.json
    end
  end

  def collections
    @collections = current_user.collections.ordered
    @collections = WallpaperCollectionStatusPopulator.new(@wallpaper, @collections).collections

    respond_to do |format|
      format.json
    end
  end

  def toggle_collect
    @collection = current_user.collections.find(collection_params[:id])

    if @collection.collected?(@wallpaper)
      @collection.uncollect!(@wallpaper)
      @collect_status = false
    else
      @collection.collect!(@wallpaper)
      @collect_status = true
    end

    respond_to do |format|
      format.json
    end
  end

  private

  def set_user
    if params[:user_id].present?
      @user = User.find_by_username!(params[:user_id])
      authorize! :read, @user
    end
  end

  def set_wallpaper
    @wallpaper = Wallpaper.find(params[:id])
    authorize! :read, @wallpaper
  end

  def create_wallpaper_params
    params.require(:wallpaper).permit(:purity, :image, :image_gravity, :source, tag_ids: [])
  end

  def update_wallpaper_params
    create_wallpaper_params.except(:image)
  end

  def resize_params
    params.permit(:width, :height)
  end

  def collection_params
    params.require(:collection).permit(:id)
  end

  def record_wallpaper_impression
    impressionist(@wallpaper)
  end

  def resolve_layout
    case action_name
    when 'index'
      'user_profile' if @user.present?
    when 'show'
      'fullscreen_wallpaper'
    end
  end

  def wallpaper_search_results(params, cache_params)
    wallpapers = Wallpaper.none
    begin
      Rails.cache.fetch([:wallpaper_search, cache_params], expires_in: WALLPAPER_SEARCH_CACHE_TTL) do
        wallpapers = WallpaperSearchService.new(params).execute
      end
    rescue TypeError
      logger.warn "Cannot cache wallpaper search results with params #{params}"
      wallpapers
    end
  end
end
