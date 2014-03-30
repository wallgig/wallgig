class NotifySubscribers
  include Sidekiq::Worker

  def perform(subscribable_type, subscribable_id, wallpaper_id, destroy = false)
    return unless Wallpaper.where(id: wallpaper_id).exists?

    Subscription.where(subscribable_type: subscribable_type, subscribable_id: subscribable_id).find_each do |subscription|
      collection_scope = subscription.subscriptions_wallpapers

      if destroy
        collection_scope.where(wallpaper_id: wallpaper_id).destroy_all
      else
        collection_scope.create(wallpaper_id: wallpaper_id)
      end
    end
  end
end
