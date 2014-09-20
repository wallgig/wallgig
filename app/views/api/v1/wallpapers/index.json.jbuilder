json.partial! 'api/v1/shared/paging', collection: @wallpapers

json.search do
  WallpaperSearchParams::KEYS_SCALAR.each do |key|
    json.set! key, search_options[key] if search_options.include?(key)
  end
  json.purities current_purities
  json.facets do
    json.tags @wallpapers.facets['tag']['terms'] do |tag|
      json.(tag, 'term', 'count')
      json.included true if search_options[:tags].include?(tag['term'])
      json.excluded true if search_options[:exclude_tags].include?(tag['term'])
    end
    json.categories @wallpapers.facets['category']['terms'] do |category|
      json.(category, 'term', 'count')
      json.included true if search_options[:categories].include?(category['term'])
      json.excluded true if search_options[:exclude_categories].include?(category['term'])
    end
  end
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
