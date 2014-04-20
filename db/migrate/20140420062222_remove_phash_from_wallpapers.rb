class RemovePhashFromWallpapers < ActiveRecord::Migration
  def change
    remove_column :wallpapers, :phash, :integer
  end
end
