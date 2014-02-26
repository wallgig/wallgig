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

require 'spec_helper'

describe SubscriptionsWallpaper do
  pending "add some examples to (or delete) #{__FILE__}"
end
