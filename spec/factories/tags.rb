# == Schema Information
#
# Table name: tags
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  slug                     :string(255)
#  category_id              :integer
#  purity                   :string(255)
#  coined_by_id             :integer
#  approved_by_id           :integer
#  approved_at              :datetime
#  sfw_wallpapers_count     :integer          default(0)
#  sketchy_wallpapers_count :integer          default(0)
#  nsfw_wallpapers_count    :integer          default(0)
#
# Indexes
#
#  index_tags_on_approved_by_id  (approved_by_id)
#  index_tags_on_category_id     (category_id)
#  index_tags_on_coined_by_id    (coined_by_id)
#  index_tags_on_purity          (purity)
#  index_tags_on_slug            (slug) UNIQUE
#

FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}" }
  end
end
