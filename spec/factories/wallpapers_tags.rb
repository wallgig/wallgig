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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wallpapers_tag do
    wallpaper nil
    tag nil
    added_by nil
  end
end
