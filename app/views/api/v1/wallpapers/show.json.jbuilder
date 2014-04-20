json._links do
  json.self url_for(only_path: true)
end

json.wallpaper do
  json.partial! 'wallpaper', wallpaper: @wallpaper
end
