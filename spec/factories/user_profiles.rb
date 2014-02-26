# == Schema Information
#
# Table name: user_profiles
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  cover_wallpaper_id       :integer
#  cover_wallpaper_y_offset :integer
#  country_code             :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  username_color_hex       :string(255)
#  title                    :string(255)
#  avatar_uid               :string(255)
#
# Indexes
#
#  index_user_profiles_on_cover_wallpaper_id  (cover_wallpaper_id)
#  index_user_profiles_on_user_id             (user_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_profile do
    user nil
    cover_wallpaper nil
    cover_wallpaper_y_offset 1
    country_code "MyString"
  end
end
