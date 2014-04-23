class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: :show

  # GET /notifications
  def index
    @notifications = scoped_collection.latest.page(params[:page])
  end

  # GET /notifications/1
  def show
    @notification.mark_as_read

    if actual_model = @notification.to_actual_model
      redirect_to actual_model
    else
      redirect_to notifications_url, notice: I18n.t('notifications.flashes.marked_as_read')
    end
  end

  # POST /notifications/mark_all_read
  # POST /notifications/mark_all_read.json
  def mark_all_read
    scoped_collection.mark_as_read

    respond_to do |format|
      format.html { redirect_to notifications_url, notice: I18n.t('notifications.flashes.marked_all_as_read') }
      format.json { head :no_content }
    end
  end

  # DELETE /notifications/purge
  # DELETE /notifications/purge.json
  def purge
    scoped_collection.delete_all

    respond_to do |format|
      format.html { redirect_to notifications_url, notice: I18n.t('notifications.flashes.purged') }
      format.json { head :no_content }
    end
  end

  private
    def scoped_collection
      current_user.notifications
    end

    def set_notification
      @notification = scoped_collection.find(params[:id])
    end
end
