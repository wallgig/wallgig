# renamed collection to kollection to avoid conflict

json.(kollection, :id, :name, :public, :position, :wallpapers_count)

preview_wallpaper = kollection.last_added_wallpaper
if preview_wallpaper.present?
  json.preview do
    wallpaper = preview_wallpaper.decorate
    json.(wallpaper, :purity)
    json.width Wallpaper::THUMBNAIL_WIDTH
    json.height Wallpaper::THUMBNAIL_HEIGHT
    json.url wallpaper.thumbnail_image_url # TODO don't use decorator here
  end
end
