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

class CollectionsWallpaper < ActiveRecord::Base
  belongs_to :collection
  belongs_to :wallpaper

  validates :collection_id, presence: true
  validates :wallpaper_id,  presence: true, uniqueness: { scope: :collection_id }

  acts_as_list

  after_commit :queue_notify_subscribers

  def queue_notify_subscribers
    NotifySubscribers.perform_async('Collection', collection_id, wallpaper_id, destroyed?)
  end
end
