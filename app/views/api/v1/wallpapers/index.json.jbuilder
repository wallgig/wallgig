blank_value = lambda { |_,v| v.blank? }

json._links do
  json.self url_for(search_options.reject(&blank_value))
  json.next url_for(search_options.merge(page: @wallpapers.next_page).reject(&blank_value)) unless @wallpapers.next_page.nil?
end

json.wallpapers @wallpapers do |wallpaper|
  json.extract! wallpaper, :id, :purity, :source, :created_at, :updated_at, :comments_count, :favourites_count

  json.views_count wallpaper.impressions_count

  json.url wallpaper_url(wallpaper, protocol: :http)

  json.user wallpaper.user, :username unless wallpaper.user.nil?

  json.image do
    json.file_name wallpaper.image_name
    json.gravity wallpaper.image_gravity
    json.original do
      json.width wallpaper.image_width
      json.height wallpaper.image_height
      json.url wallpaper.requested_image_url
    end
    json.thumbnail do
      json.width 250
      json.height 188
      json.url wallpaper.thumbnail_image_url
    end
  end

  json.tags wallpaper.tags do |tag|
    json.id tag.slug
    json.extract! tag, :name, :purity
  end
end
