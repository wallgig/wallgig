class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.latest.page(params[:page])
  end

  def mark_as_read
    current_user.notifications.mark_as_read

    respond_to do |format|
      format.html { redirect_to notifications_url, notice: I18n.t('notifications.flashes.marked_as_read') }
      format.json { head :no_content }
    end
  end
end
