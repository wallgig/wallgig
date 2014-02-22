class CreateSubscriptionsWallpapers < ActiveRecord::Migration
  def change
    create_table :subscriptions_wallpapers do |t|
      t.references :subscription, index: true
      t.references :wallpaper, index: true
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
