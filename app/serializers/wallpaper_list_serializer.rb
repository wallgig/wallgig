class WallpaperListSerializer < ActiveModel::Serializer
  attributes :id, :purity, :image_width, :image_height,
    :favourites_count, :impressions_count,
    :tag_list

  # attributes provided by WallpaperDecorator
  attributes :thumbnail_image_url, :thumbnail_image_width, :thumbnail_image_height, :favourited
end
