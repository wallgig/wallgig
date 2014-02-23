class NotifySubscribers
  include Sidekiq::Worker

  def perform(subscribable_type, subscribable_id, wallpaper_id, destroy = false)
    Subscription.where(subscribable_type: subscribable_type, subscribable_id: subscribable_id).find_each do |subscription|
      collection_scope = subscription.subscriptions_wallpapers

      if destroy
        collection_scope.where(wallpaper_id: wallpaper_id).destroy_all
      else
        begin
          collection_scope.create!(wallpaper_id: wallpaper_id)
        rescue ActiveRecord::RecordNotUnique
        end
      end
    end
  end
end
