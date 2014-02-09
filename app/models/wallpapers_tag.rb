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

class WallpapersTag < ActiveRecord::Base
  belongs_to :wallpaper
  belongs_to :tag
  belongs_to :added_by, class_name: 'User'

  validates :wallpaper_id, presence: true
  validates :tag_id,       presence: true, uniqueness: { scope: :wallpaper_id }
end
