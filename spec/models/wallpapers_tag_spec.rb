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

require 'spec_helper'

describe WallpapersTag do
  pending "add some examples to (or delete) #{__FILE__}"
end
