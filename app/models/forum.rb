# == Schema Information
#
# Table name: forums
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  description :text
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  color       :string(255)
#  text_color  :string(255)
#  can_read    :boolean          default(TRUE)
#  can_post    :boolean          default(TRUE)
#  can_comment :boolean          default(TRUE)
#
# Indexes
#
#  index_forums_on_slug  (slug)
#

class Forum < ActiveRecord::Base
  has_many :topics

  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_list

  validates :name, presence: true

  scope :ordered, -> { order(position: :asc) }
  scope :list,    -> (current_ability) { accessible_by(current_ability, :read).ordered }

  def self.uncategorized
    find_by!(slug: 'uncategorized')
  end
end
