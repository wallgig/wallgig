# == Schema Information
#
# Table name: subscriptions_wallpapers
#
#  id              :integer          not null, primary key
#  subscription_id :integer
#  wallpaper_id    :integer
#  read            :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class SubscriptionsWallpaper < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :wallpaper

  validates :subscription_id, presence: true
  validates :wallpaper_id, presence: true
end
