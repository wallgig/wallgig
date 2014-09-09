json.collections @collections do |collection|
  json.(collection, :id, :name, :public, :position, :sfw_wallpapers_count, :sketchy_wallpapers_count, :nsfw_wallpapers_count)

  json.preview do
    json.width Wallpaper::THUMBNAIL_WIDTH
    json.height Wallpaper::THUMBNAIL_HEIGHT
    json.url collection.last_added_wallpaper.decorate.thumbnail_image_url # TODO don't use decorator here
  end
end
