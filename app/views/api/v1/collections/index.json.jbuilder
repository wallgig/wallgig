json.collections @collections do |collection|
  json.(collection, :id, :name, :public, :position, :sfw_wallpapers_count, :sketchy_wallpapers_count, :nsfw_wallpapers_count)

  json.preview do
    wallpaper = collection.last_added_wallpaper.decorate
    json.(wallpaper, :purity)
    json.width Wallpaper::THUMBNAIL_WIDTH
    json.height Wallpaper::THUMBNAIL_HEIGHT
    json.url wallpaper.thumbnail_image_url # TODO don't use decorator here
  end
end
