# == Schema Information
#
# Table name: favourites
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  wallpaper_id  :integer
#  collection_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_favourites_on_collection_id  (collection_id)
#  index_favourites_on_user_id        (user_id)
#  index_favourites_on_wallpaper_id   (wallpaper_id)
#

FactoryGirl.define do
  factory :favourite do
    user
    wallpaper
  end
end
