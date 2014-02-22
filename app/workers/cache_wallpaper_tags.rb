class CacheWallpaperTags
  include Sidekiq::Worker

  def perform(options = {})
    if options[:wallpaper_id].present?
      Wallpaper.where(id: options[:wallpaper_id]).find_each(&:cache_tag_list)
    end

    if options[:tag_id].present?
      Tag.where(id: options[:tag_id]).find_each do |tag|
        tag.wallpapers.find_each(&:cache_tag_list)
      end
    end
  end
end
