class AddWallpapersCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :wallpapers_count, :integer, default: 0
  end
end
