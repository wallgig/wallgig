class AddCommentsCountToWallpapers < ActiveRecord::Migration
  def change
    add_column :wallpapers, :comments_count, :integer, default: 0
  end
end
