# == Schema Information
#
# Table name: forums
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  slug             :string(255)
#  description      :text
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  guest_can_read   :boolean          default(TRUE)
#  guest_can_post   :boolean          default(TRUE)
#  guest_can_reply  :boolean          default(TRUE)
#  member_can_read  :boolean          default(TRUE)
#  member_can_post  :boolean          default(TRUE)
#  member_can_reply :boolean          default(TRUE)
#  color            :string(255)
#  text_color       :string(255)
#

class Forum < ActiveRecord::Base
  has_many :topics, as: :owner
  # has_many :topics, class_name: 'ForumTopic'
  # has_one :latest_topic, -> { order(updated_at: :desc) }, class_name: 'ForumTopic'

  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_list

  validates :name, presence: true

  scope :ordered, -> { order(position: :asc) }

  def self.uncategorized
    friendly.find('uncategorized')
  end

  def label_css_style

  end
end
