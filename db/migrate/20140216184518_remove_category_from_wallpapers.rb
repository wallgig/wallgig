class RemoveCategoryFromWallpapers < ActiveRecord::Migration
  def change
    remove_reference :wallpapers, :category, index: true
  end
end
