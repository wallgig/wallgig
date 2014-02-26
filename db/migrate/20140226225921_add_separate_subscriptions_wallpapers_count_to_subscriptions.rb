class AddSeparateSubscriptionsWallpapersCountToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :sfw_subscriptions_wallpapers_count, :integer, null: false, default: 0
    add_column :subscriptions, :sketchy_subscriptions_wallpapers_count, :integer, null: false, default: 0
    add_column :subscriptions, :nsfw_subscriptions_wallpapers_count, :integer, null: false, default: 0
    remove_column :subscriptions, :subscriptions_wallpapers_count, :integer, default: 0
  end
end
