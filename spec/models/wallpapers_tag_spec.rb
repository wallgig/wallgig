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

require 'spec_helper'

describe WallpapersTag do
  pending "add some examples to (or delete) #{__FILE__}"
end
