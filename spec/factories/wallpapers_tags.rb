# == Schema Information
#
# Table name: wallpapers_tags
#
#  id           :integer          not null, primary key
#  wallpaper_id :integer
#  tag_id       :integer
#  added_by_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_wallpapers_tags_on_added_by_id              (added_by_id)
#  index_wallpapers_tags_on_tag_id                   (tag_id)
#  index_wallpapers_tags_on_wallpaper_id             (wallpaper_id)
#  index_wallpapers_tags_on_wallpaper_id_and_tag_id  (wallpaper_id,tag_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wallpapers_tag do
    wallpaper
    tag
    association :added_by, factory: :user
  end
end
