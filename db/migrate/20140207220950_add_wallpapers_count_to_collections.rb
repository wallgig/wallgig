class AddWallpapersCountToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :sfw_wallpapers_count, :integer, default: 0
    add_column :collections, :sketchy_wallpapers_count, :integer, default: 0
    add_column :collections, :nsfw_wallpapers_count, :integer, default: 0
  end
end
