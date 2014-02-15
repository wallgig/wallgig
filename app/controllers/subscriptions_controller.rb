class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscribable, except: [:index]
  before_action :set_subscription, except: [:index]

  respond_to :json, only: [:toggle]

  def index
    @subscriptions = Subscription.all
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
    if params[:wallpaper_id].present?
      @subscribable = Wallpaper.find(params[:wallpaper_id])
    elsif params[:tag_id].present?
      @subscribable = Tag.friendly.find(params[:tag_id])
    end

    authorize! :read, @subscribable
  end

  def set_subscription
    @subscription = current_user.subscriptions.find_by(subscribable: @subscribable)
  end
end
