class CollectionsController < ApplicationController
  before_action :set_user
  before_action :set_collection, only: [:show]

  layout :resolve_layout

  impressionist actions: [:show]

  # GET /collections
  # GET /users/1/collections
  def index
    @should_apply_purity_settings = true
    minimum_wallpapers            = 4

    if @user.present?
      # Viewing user's collections. They are ordered.
      @collections = @user.collections.ordered

      @should_apply_purity_settings = false if myself?
      minimum_wallpapers = 0
    else
      @collections = Collection.latest
    end

    if @should_apply_purity_settings
      @collections = @collections.not_empty_for_purities(current_purities, minimum_wallpapers)
    end

    # Common
    @collections = @collections.includes(user: :profile)
                               .accessible_by(current_ability, :read)
                               .page(params[:page]).per(20)

    if request.xhr?
      render partial: 'list', layout: false, locals: { collections: @collections, should_apply_purity_settings: @should_apply_purity_settings }
    end
  end

  # GET /collections/1
  def show
    @wallpapers = @collection.ordered_wallpapers
                             .accessible_by(current_ability, :read)
                             .page(params[:page])

    @wallpapers = @wallpapers.with_purities(current_purities) unless myself?(@collection.user)

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
    if params[:user_id].present?
      @user = User.find_by_username!(params[:user_id])
      authorize! :read, @user
    end
  end

  def set_collection
    @collection = Collection.find(params[:id])
    authorize! :read, @collection
  end

  def resolve_layout
    if @user.present?
      'user_profile'
    else
      'application'
    end
  end

end
