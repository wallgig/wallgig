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

class WallpapersTag < ActiveRecord::Base
  belongs_to :wallpaper, inverse_of: :wallpapers_tags
  belongs_to :tag
  belongs_to :added_by, class_name: 'User'

  validates :tag_id, presence: true, uniqueness: { scope: :wallpaper_id }

  delegate :name, :purity, :category_name, to: :tag

  after_commit :queue_update_wallpaper_tags, on: :destroy
  after_commit :queue_notify_subscribers

  def queue_update_wallpaper_tags
    CacheWallpaperTags.perform_async(wallpaper_id: wallpaper_id)
  end

  def queue_notify_subscribers
    NotifySubscribers.perform_async('Tag', tag_id, wallpaper_id, destroyed?)
  end
end
