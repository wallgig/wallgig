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

require 'spec_helper'

describe CollectionsWallpaper do
  pending "add some examples to (or delete) #{__FILE__}"
end
