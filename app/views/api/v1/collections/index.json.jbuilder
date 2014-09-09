json.collections @collections do |collection|
  json.(collection, :id, :name, :public, :position, :sfw_wallpapers_count, :sketchy_wallpapers_count, :nsfw_wallpapers_count)
end
