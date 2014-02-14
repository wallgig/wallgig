class AddSeparateWallpaperPurityCountersToTags < ActiveRecord::Migration
  def change
    add_column :tags, :sfw_wallpapers_count, :integer, default: 0
    add_column :tags, :sketchy_wallpapers_count, :integer, default: 0
    add_column :tags, :nsfw_wallpapers_count, :integer, default: 0
    remove_column :tags, :wallpapers_count, :integer, default: 0
  end
end
