json.array! @wallpapers do |wallpaper|
  json.extract! wallpaper, :id, :purity, :impressions_count
  json.path wallpaper.path_with_resolution
  json.thumbnail_image do
    json.url wallpaper.thumbnail_image_url
    json.width 250
    json.height 188
  end
  json.image do
    json.width wallpaper.image_width
    json.height wallpaper.image_height
  end
end
