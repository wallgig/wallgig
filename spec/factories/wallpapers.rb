# == Schema Information
#
# Table name: wallpapers
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  purity              :string(255)
#  processing          :boolean          default(TRUE)
#  image_uid           :string(255)
#  image_name          :string(255)
#  image_width         :integer
#  image_height        :integer
#  created_at          :datetime
#  updated_at          :datetime
#  thumbnail_image_uid :string(255)
#  impressions_count   :integer          default(0)
#  cached_tag_list     :text
#  image_gravity       :string(255)      default("c")
#  favourites_count    :integer          default(0)
#  source              :text
#  scrape_source       :string(255)
#  scrape_id           :string(255)
#  image_hash          :string(255)
#  comments_count      :integer          default(0)
#  approved_by_id      :integer
#  approved_at         :datetime
#  cooked_source       :text
#  colors              :text
#
# Indexes
#
#  index_wallpapers_on_approved_at     (approved_at)
#  index_wallpapers_on_approved_by_id  (approved_by_id)
#  index_wallpapers_on_image_hash      (image_hash)
#  index_wallpapers_on_purity          (purity)
#  index_wallpapers_on_user_id         (user_id)
#

FactoryGirl.define do
  factory :wallpaper do
    ignore do
      tags_count 2
    end

    user
    image File.new(Rails.root.join('spec', 'wallpapers', 'test.jpg'))
    processing false

    after(:build) do |wallpaper, evaluator|
      wallpaper.tags = create_list(:tag, evaluator.tags_count)
    end

    factory(:sfw_wallpaper) { purity :sfw }
    factory(:sketchy_wallpaper) { purity :sketchy }
    factory(:nsfw_wallpaper) { purity :nsfw }
  end
end
