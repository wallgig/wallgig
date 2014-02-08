class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show]
  before_action :set_parent
  layout :resolve_layout
  impressionist actions: [:show]

  # GET /collections
  def index
    @should_apply_purity_settings = true

    if @user.present?
      # Viewing user's collections. They are ordered.
      @collections = @user.collections.ordered
      @should_apply_purity_settings = false if myself?
    else
      @collections = Collection.latest
    end

    @collections = @collections.includes(:owner)
                               .accessible_by(current_ability, :read)
                               .page(params[:page])

    if @should_apply_purity_settings
      @collections = @collections.with_purities(current_purities)
    end

    if request.xhr?
      render partial: 'list', layout: false, locals: { collections: @collections, should_apply_purity_settings: @should_apply_purity_settings }
    end
  end

  # GET /collections/1
  def show
    @wallpapers = @collection.ordered_wallpapers
                             .accessible_by(current_ability, :read)
                             .page(params[:page])

    @wallpapers = @wallpapers.with_purities(current_purities) unless user_signed_in? && @collection.owner_type == 'User' && current_user.id == @collection.owner_id

    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { user: current_user })

    if request.xhr?
      render partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }
    end
  end

  private

  def set_parent
    if params[:user_id].present?
      @parent = @user = User.find_by_username!(params[:user_id])
    elsif params[:group_id].present?
      @parent = @group = Group.friendly.find(params[:group_id])
    end
    authorize! :read, @parent if @parent.present?
  end

  def set_collection
    @collection = Collection.find(params[:id])
    authorize! :read, @collection
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collection_params
    params.require(:collection).permit(:name, :public)
  end

  def resolve_layout
    if @parent.is_a?(User) || @user.present? # TODO deprecate
      'user_profile'
    elsif @parent.is_a?(Group)
      'group'
    else
      'application'
    end
  end

end
