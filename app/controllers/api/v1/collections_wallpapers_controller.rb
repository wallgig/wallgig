class Api::V1::CollectionsWallpapersController < Api::V1::BaseController
  before_action :set_collection

  # POST /api/v1/collections/:collection_id/wallpapers.json
  def create
    wallpaper = Wallpaper.find(params[:wallpaper_id])
    authorize! :read, wallpaper

    @collection.collect!(wallpaper) unless @collection.collected?(wallpaper)

    respond_to do |format|
      format.json { render json: true, status: :created }
    end
  end

  private

  def set_collection
    # TODO don't scope to current user
    @collection = current_user.collections.find(params[:collection_id])
  end
end
