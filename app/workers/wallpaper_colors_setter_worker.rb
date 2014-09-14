class WallpaperColorsSetterWorker
  include Sidekiq::Worker

  def perform(wallpaper_id)
    wallpaper = Wallpaper.find(wallpaper_id)
    wallpaper.set_colors
    wallpaper.save! validate: false
  rescue ActiveRecord::RecordNotFound => e
    logger.warn e.to_s
  end
end
