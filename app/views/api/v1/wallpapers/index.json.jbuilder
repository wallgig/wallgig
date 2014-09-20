json.partial! 'api/v1/shared/paging', collection: @wallpapers

json.facets do
  json.tags @wallpapers.facets['tag']['terms']
  json.categories @wallpapers.facets['category']['terms']
end

json.wallpapers @wallpapers do |wallpaper|
  json.(wallpaper, :id, :purity, :favourites_count)
  json.views_count wallpaper.impressions_count
  json.url wallpaper_url(wallpaper)
  json.user wallpaper.user.try(:username)

  json.image do
    json.original do
      json.width wallpaper.image_width
      json.height wallpaper.image_height
    end

    if wallpaper.thumbnail_image.present?
      json.thumbnail do
        json.width Wallpaper::THUMBNAIL_WIDTH
        json.height Wallpaper::THUMBNAIL_HEIGHT
        json.url wallpaper.thumbnail_image_url
      end
    else
      json.thumbnail nil
    end
  end

  json.favourited wallpaper.favourited? if user_signed_in?
end
