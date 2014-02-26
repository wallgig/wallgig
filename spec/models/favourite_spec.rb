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

require 'spec_helper'

describe Favourite do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:wallpaper).counter_cache(true) }
    it { should belong_to(:collection).touch(true) }
  end
end
