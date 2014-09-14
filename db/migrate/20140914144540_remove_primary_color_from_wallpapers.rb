class RemovePrimaryColorFromWallpapers < ActiveRecord::Migration
  def change
    remove_reference :wallpapers, :primary_color, index: true
  end
end
