# == Schema Information
#
# Table name: collections_wallpapers
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  wallpaper_id  :integer
#  position      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_collections_wallpapers_on_collection_id  (collection_id)
#  index_collections_wallpapers_on_wallpaper_id   (wallpaper_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collections_wallpaper do
    collection nil
    wallpaper nil
    position 1
  end
end
