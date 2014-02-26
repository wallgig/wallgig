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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscriptions_wallpaper do
    subscription nil
    wallpaper nil
    read false
  end
end
