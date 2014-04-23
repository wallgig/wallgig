json.partial! 'api/v1/shared/page_meta', collection: @notifications


json._links do
  json.self url_for(notification_params.merge(only_path: true))
  json.next url_for(notification_params.merge(page: @notifications.next_page, only_path: true)) unless @notifications.next_page.nil?
  json.mark_read mark_read_api_v1_notification_path(':id')
end

json.notifications @notifications do |notification|
  json.extract! notification, :id, :message, :read, :created_at

  if notification.to_actual_model.nil?
    json.url notifications_path
  else
    json.url url_for(notification.to_actual_model, only_path: true)
  end
end
