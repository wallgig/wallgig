class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.latest.page(params[:page])
  end

  def mark_as_read
    if params[:id].present?
      # Mark single notification as read
      current_user.notifications.find(params[:id]).mark_as_read

      respond_to do |format|
        format.html { redirect_to notifications_url, notice: I18n.t('notifications.flashes.marked_as_read') }
        format.json { head :no_content }
      end
    else
      # Mark all notifications as read
      current_user.notifications.mark_as_read

      respond_to do |format|
        format.html { redirect_to notifications_url, notice: I18n.t('notifications.flashes.marked_all_as_read') }
        format.json { head :no_content }
      end
    end

  end
end
