class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscribable, except: [:index, :collections, :tags]
  before_action :set_subscription, except: [:index, :collections, :tags]

  respond_to :json, only: [:toggle]

  def index
    @wallpapers = Wallpaper.subscribed_users_by_user(current_user)
                           .accessible_by(current_ability, :read)
                           .with_purities(current_purities)
                           .page(params[:page])

    render_index('User')
  end

  def collections
    @wallpapers = Wallpaper.subscribed_collections_by_user(current_user)
                           .accessible_by(current_ability, :read)
                           .with_purities(current_purities)
                           .page(params[:page])

    render_index('Collection')
  end

  def tags
    @wallpapers = Wallpaper.subscribed_tags_by_user(current_user)
                           .accessible_by(current_ability, :read)
                           .with_purities(current_purities)
                           .page(params[:page])

    render_index('Tag')
  end

  def show
    @wallpapers = Wallpaper.in_subscription(@subscription)
                           .accessible_by(current_ability, :read)
                           .with_purities(current_purities)
                           .page(params[:page])

    render_index(@subscription.subscribable_type)
  end

  def render_index(subscribable_type)
    @subscriptions = current_user.subscriptions.by_type(subscribable_type)

    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { current_user: current_user })

    if request.xhr?
      render partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }
    else
      render action: 'index'
    end
  end

  def toggle
    if @subscription.present?
      @subscription.destroy
      @subscription_state = false

      render action: 'status'
    else
      @subscription = current_user.subscriptions.new(subscribable: @subscribable)
      @subscription_state = true

      if @subscription.save
        render action: 'status'
      else
        render json: @subscription.errors.full_messages, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to @subscribable, notice: 'Subscription was successfully destroyed.' }
      format.json
    end
  end

  private

  def set_subscribable
    if params[:collection_id].present?
      @subscribable = Collection.find(params[:collection_id])
    elsif params[:tag_id].present?
      @subscribable = Tag.friendly.find(params[:tag_id])
    elsif params[:user_id].present?
      @subscribable = User.find_by_username!(params[:user_id])
    end

    authorize! :read, @subscribable
    authorize! :subscribe, @subscribable
  end

  def set_subscription
    if @subscribable.present?
      @subscription = current_user.subscriptions.find_by(subscribable: @subscribable)
    else
      @subscription = current_user.subscriptions.find(params[:id])
    end
  end
end
