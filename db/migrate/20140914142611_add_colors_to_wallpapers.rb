class AddColorsToWallpapers < ActiveRecord::Migration
  def change
    add_column :wallpapers, :colors, :text
  end
end
