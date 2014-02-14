class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscribable, except: [:index]
  before_action :set_subscription, except: [:index]

  def index
    @subscriptions = Subscription.all
  end

  def toggle
    if @subscription.present?
      destroy
    else
      create
    end
  end

  def create
    @subscription = current_user.subscriptions.new(subscribable: @subscribable)

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to @subscribable, notice: 'Subscription was successfully created.' }
        format.json { render action: 'show', status: :created, location: @subscription }
      els
        format.html { redirect_to @subscribable, notice: 'Cannot create subscription.' }
        format.json { render json: @subscription.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to @subscribable, notice: 'Subscription was successfully destroyed.' }
      format.json { head :no_content }
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
