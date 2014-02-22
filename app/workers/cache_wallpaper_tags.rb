class CacheWallpaperTags
  include Sidekiq::Worker

  def perform(wallpaper_id: nil, tag_id: nil)
    Wallpaper.where(id: wallpaper_id).find_each(&:cache_tag_list) unless wallpaper_id.nil?

    unless tag_id.nil?
      Tag.where(id: tag_id).find_each do |tag|
        tag.wallpapers.find_each(&:cache_tag_list)
      end
    end
  end
end
