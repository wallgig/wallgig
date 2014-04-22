class Api::V1::NotificationsController < Api::V1::BaseController
  before_action :authenticate_user!
  helper_method :notification_params

  # GET /api/v1/notifications.json
  def index
    @notifications = current_user_notifications
  end

  # GET /api/v1/notifications/unread.json
  def unread
    @notifications = current_user_notifications.unread
    render action: 'index'
  end

  private
    def current_user_notifications
      current_user.notifications
        .page(notification_params[:page])
        .per(notification_params[:limit])
    end

    def notification_params
      params.permit(:page, :limit)
    end
end
