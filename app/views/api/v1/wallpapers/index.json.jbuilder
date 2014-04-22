blank_value = lambda { |_,v| v.blank? }

json.partial! 'api/v1/shared/page_meta', collection: @wallpapers

json._links do
  json.self url_for(search_options.reject(&blank_value))
  json.next url_for(search_options.merge(page: @wallpapers.next_page).reject(&blank_value)) unless @wallpapers.next_page.nil?
end

json.wallpapers @wallpapers, partial: 'wallpaper', as: :wallpaper
