class ChangeSourceFromStringToTextForWallpapers < ActiveRecord::Migration
  def up
    change_column :wallpapers, :source, :text
    change_column :wallpapers, :cooked_source, :text
  end

  def down
    change_column :wallpapers, :source, :string
    change_column :wallpapers, :cooked_source, :string
  end
end
