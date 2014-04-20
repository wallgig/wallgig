class AddCookedSourceToWallpapers < ActiveRecord::Migration
  def change
    add_column :wallpapers, :cooked_source, :string
  end
end
