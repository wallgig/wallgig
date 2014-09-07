class AddIndexToCollectionsAndCollectionsWallpapersPosition < ActiveRecord::Migration
  def change
    add_index :collections, :position
    add_index :collections_wallpapers, :position
  end
end
