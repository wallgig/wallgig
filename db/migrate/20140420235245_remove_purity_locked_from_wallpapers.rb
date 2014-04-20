class RemovePurityLockedFromWallpapers < ActiveRecord::Migration
  def change
    remove_column :wallpapers, :purity_locked, :boolean
  end
end
