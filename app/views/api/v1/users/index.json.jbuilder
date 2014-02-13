json.array! @users do |user|
  if @includes.include? 'basic'
    json.extract! user, :username
    json.url user_path(user)
  end
  json.avatar_url   user_avatar_url(user, params[:avatar_size]) if @includes.include? 'avatar_url'
  json.username_tag username_tag(user)                          if @includes.include? 'username_tag'
  json.status_tag   user_online_status_tag(user)                if @includes.include? 'status_tag'
end