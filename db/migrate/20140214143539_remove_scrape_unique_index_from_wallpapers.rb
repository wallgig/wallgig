class RemoveScrapeUniqueIndexFromWallpapers < ActiveRecord::Migration
  def change
    remove_index :wallpapers, name: 'index_wallpapers_on_scrape_source_and_scrape_id'
  end
end
