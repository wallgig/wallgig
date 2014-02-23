class AddSubscriptionsWallpapersCountToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :subscriptions_wallpapers_count, :integer, default: 0
  end
end
