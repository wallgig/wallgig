module WallpapersHelper
  def image_tag_for_wallpaper_stage(wallpaper)
    style = [
      "background: url(#{wallpaper.image.thumb('320x320').url}) no-repeat center center fixed",
      'background-size: contain'
    ].join(';')

    image_tag(
      wallpaper.requested_image_url,
      :width => wallpaper.requested_image_resolution.width,
      :height => wallpaper.requested_image_resolution.height,
      :class => "img-wallpaper img-#{wallpaper.format} state-1",
      :style => style
    )
  end
end
