class CreateSubscriptionsWallpapers < ActiveRecord::Migration
  def change
    create_table :subscriptions_wallpapers do |t|
      t.references :subscription, index: true
      t.references :wallpaper, index: true

      t.timestamps
    end

    add_index :subscriptions_wallpapers, [:subscription_id, :wallpaper_id], unique: true, name: 'index_subscriptions_wallpapers_on_subscription_and_wallpaper'
  end
end
