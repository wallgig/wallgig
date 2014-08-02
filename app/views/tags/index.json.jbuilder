json.partial! 'shared/api/page_meta', collection: @tags

json.tags @tags do |tag|
  json.extract! tag, :id, :name, :slug, :category_name, :purity,
                :sfw_wallpapers_count, :sketchy_wallpapers_count, :nsfw_wallpapers_count
end
