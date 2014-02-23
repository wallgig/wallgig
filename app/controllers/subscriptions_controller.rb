class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscribable, except: [:index, :collections, :tags]
  before_action :set_subscription, except: [:index, :collections, :tags, :mark_type_read]

  respond_to :json, only: [:toggle]

  def index
    render_index 'User'
  end

  def collections
    render_index 'Collection'
  end

  def tags
    render_index 'Tag'
  end

  def render_index(subscribable_type)
    @subscribable_type = subscribable_type

    @wallpapers = current_user.subscribed_wallpapers_by_subscribable_type(@subscribable_type)
                              .accessible_by(current_ability, :read)
                              .with_purities(current_purities)
                              .page(params[:page])
    @wallpapers = WallpapersDecorator.new(@wallpapers, context: { current_user: current_user })

    @subscriptions = current_user.subscriptions.by_type(@subscribable_type)

    if request.xhr?
      render partial: 'wallpapers/list', layout: false, locals: { wallpapers: @wallpapers }
    else
      render action: 'index'
    end
  end

  def show
    @subscribable_type = @subscription.subscribable_type

    @wallpapers = @subscription.wallpapers
                               .accessible_by(current_ability, :read)
                               .with_purities(current_purities)
                               .page(params[:page])

    render_index
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

  def mark_type_read
    subscriptions_params = params.permit(:type)
    raise AccessDenied unless ['user', 'collection', 'tag'].include?(subscriptions_params[:type])

    current_user.subscriptions.by_type(subscriptions_params[:type].camelize).mark_all_as_read!

    redirect_to :back, notice: 'Subscription was successfully marked as read.'
  end

  def mark_read
    @subscription.mark_all_as_read!

    redirect_to @subscription, notice: 'Subscription was successfully marked as read.'
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

    if @subscribable.present?
      authorize! :read, @subscribable
      authorize! :subscribe, @subscribable
    end
  end

  def set_subscription
    if @subscribable.present?
      @subscription = current_user.subscriptions.find_by(subscribable: @subscribable)
    else
      @subscription = current_user.subscriptions.find(params[:id])
    end
  end

  def current_purities
    ['sfw', 'sketchy', 'nsfw']
  end
end
