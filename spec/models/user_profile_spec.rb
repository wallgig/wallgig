# == Schema Information
#
# Table name: user_profiles
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  cover_wallpaper_id       :integer
#  cover_wallpaper_y_offset :integer
#  country_code             :string(2)
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

require 'spec_helper'

describe UserProfile do
  pending "add some examples to (or delete) #{__FILE__}"
end
