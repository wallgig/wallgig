class WallpaperResizerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :wallpapers

  def perform(wallpaper_id)
    @wallpaper = Wallpaper.find(wallpaper_id)
    generate_images
    @wallpaper.save!
  end

  def generate_images
    generate_image(
      :image,
      :thumbnail_image,
      "#{Wallpaper::THUMBNAIL_WIDTH}x#{Wallpaper::THUMBNAIL_HEIGHT}\##{@wallpaper.image_gravity}",
      '-quality 70'
    )
  end

  def generate_image(source, target, size, encode_opts)
    source = @wallpaper.send(source)
    if source.present?
      image = source.thumb(size).encode(:jpg, encode_opts)
      @wallpaper.send("#{target}=", image)
    else
      raise "Source doesn't exist yet"
    end
  end
end