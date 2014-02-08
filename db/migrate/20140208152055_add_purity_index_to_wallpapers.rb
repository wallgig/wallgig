class AddPurityIndexToWallpapers < ActiveRecord::Migration
  def change
    add_index :wallpapers, :purity
  end
end
