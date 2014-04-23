class Api::V1::NotificationsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_notification, only: [:mark_read]

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

  # POST /api/v1/notifications/1/mark_read.json
  def mark_read
    @notification.mark_as_read
    head :no_content
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

    def set_notification
      @notification = current_user.notifications.find(params[:id])
    end
end
