# == Schema Information
#
# Table name: wallpapers
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  purity                :string(255)
#  processing            :boolean          default(TRUE)
#  image_uid             :string(255)
#  image_name            :string(255)
#  image_width           :integer
#  image_height          :integer
#  created_at            :datetime
#  updated_at            :datetime
#  thumbnail_image_uid   :string(255)
#  primary_color_id      :integer
#  impressions_count     :integer          default(0)
#  cached_tag_list       :text
#  image_gravity         :string(255)      default("c")
#  favourites_count      :integer          default(0)
#  purity_locked         :boolean          default(FALSE)
#  source                :string(255)
#  phash                 :integer
#  scrape_source         :string(255)
#  scrape_id             :string(255)
#  image_hash            :string(255)
#  cached_votes_total    :integer          default(0)
#  cached_votes_score    :integer          default(0)
#  cached_votes_up       :integer          default(0)
#  cached_votes_down     :integer          default(0)
#  cached_weighted_score :integer          default(0)
#  comments_count        :integer          default(0)
#  approved_by_id        :integer
#  approved_at           :datetime
#
# Indexes
#
#  index_wallpapers_on_approved_at            (approved_at)
#  index_wallpapers_on_approved_by_id         (approved_by_id)
#  index_wallpapers_on_cached_votes_down      (cached_votes_down)
#  index_wallpapers_on_cached_votes_score     (cached_votes_score)
#  index_wallpapers_on_cached_votes_total     (cached_votes_total)
#  index_wallpapers_on_cached_votes_up        (cached_votes_up)
#  index_wallpapers_on_cached_weighted_score  (cached_weighted_score)
#  index_wallpapers_on_image_hash             (image_hash)
#  index_wallpapers_on_phash                  (phash)
#  index_wallpapers_on_primary_color_id       (primary_color_id)
#  index_wallpapers_on_purity                 (purity)
#  index_wallpapers_on_user_id                (user_id)
#

FactoryGirl.define do
  factory :wallpaper do
    user
    image File.new(Rails.root.join('spec', 'wallpapers', 'test.jpg'))
    processing false

    factory(:sfw_wallpaper) { purity :sfw }
    factory(:sketchy_wallpaper) { purity :sketchy }
    factory(:nsfw_wallpaper) { purity :nsfw }
  end
end
