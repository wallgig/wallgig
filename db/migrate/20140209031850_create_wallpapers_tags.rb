class CreateWallpapersTags < ActiveRecord::Migration
  def change
    create_table :wallpapers_tags do |t|
      t.references :wallpaper, index: true
      t.references :tag, index: true
      t.references :added_by, index: true

      t.timestamps
    end
    add_index :wallpapers_tags, [:wallpaper_id, :tag_id], unique: true
  end
end
