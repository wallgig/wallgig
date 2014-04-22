json.partial! 'api/v1/shared/page_meta', collection: @notifications


json._links do
  json.self url_for(notification_params.merge(only_path: true))
  json.next url_for(notification_params.merge(page: @notifications.next_page, only_path: true)) unless @notifications.next_page.nil?
end

json.notifications @notifications do |notification|
  json.extract! notification, :message, :read, :created_at
end
