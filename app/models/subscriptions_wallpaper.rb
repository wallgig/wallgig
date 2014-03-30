# == Schema Information
#
# Table name: subscriptions_wallpapers
#
#  id              :integer          not null, primary key
#  subscription_id :integer
#  wallpaper_id    :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_subscriptions_wallpapers_on_subscription_and_wallpaper  (subscription_id,wallpaper_id) UNIQUE
#  index_subscriptions_wallpapers_on_subscription_id             (subscription_id)
#  index_subscriptions_wallpapers_on_wallpaper_id                (wallpaper_id)
#

class SubscriptionsWallpaper < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :wallpaper

  validates :subscription_id, presence: true
  validates :wallpaper_id, presence: true, uniqueness: { scope: :subscription_id }

  # TODO refactor into concerns
  after_create :increment_subscriptions_wallpapers_count
  after_destroy :decrement_subscriptions_wallpapers_count

  def increment_subscriptions_wallpapers_count
    Subscription.increment_counter(Subscription.counter_name_for(wallpaper), subscription_id)
  end

  def decrement_subscriptions_wallpapers_count
    Subscription.decrement_counter(Subscription.counter_name_for(wallpaper), subscription_id)
  end
end
