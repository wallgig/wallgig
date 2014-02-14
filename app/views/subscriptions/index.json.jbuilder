json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :user_id, :subscribable_id, :subscribable_type, :last_visited_at
  json.url subscription_url(subscription, format: :json)
end
