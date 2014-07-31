module WallpapersHelper
  def image_tag_for_wallpaper_stage(wallpaper)
    lowres_src = wallpaper.image.thumb('320x320').url
    highres_src = wallpaper.requested_image_url

    image_tag(
      lowres_src,
      :width => wallpaper.requested_image_resolution.width,
      :height => wallpaper.requested_image_resolution.height,
      :class => "img-wallpaper img-#{wallpaper.format} state-1",
      :data => {
        :highres_src => highres_src
      }
    )
  end
end
