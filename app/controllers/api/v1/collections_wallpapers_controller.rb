class Api::V1::CollectionsWallpapersController < Api::V1::BaseController
  before_action :set_collection

  # POST /api/v1/collections/:collection_id/wallpapers.json
  def create
    wallpaper = Wallpaper.find(params[:wallpaper_id])
    authorize! :read, wallpaper

    unless @collection.collected?(wallpaper)
      @collection.collect!(wallpaper)
      @collection.reload # needed to reload wallpapers count
    end

    respond_to do |format|
      format.json { render status: :created }
    end
  end

  private

  def set_collection
    # TODO don't scope to current user
    @collection = current_user.collections.find(params[:collection_id])
  end
end
