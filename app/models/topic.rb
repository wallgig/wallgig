# == Schema Information
#
# Table name: topics
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  title                :string(255)
#  content              :text
#  cooked_content       :text
#  pinned               :boolean          default(FALSE)
#  locked               :boolean          default(FALSE)
#  hidden               :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  forum_id             :integer
#  comments_count       :integer          default(0)
#  last_commented_at    :datetime
#  last_commented_by_id :integer
#

class Topic < ActiveRecord::Base
  MODERATION_ACTIONS = [:pin, :unpin, :lock, :unlock, :hide, :unhide]

  belongs_to :forum
  belongs_to :user
  belongs_to :last_commented_by, class_name: 'User'

  acts_as_commentable

  include Reportable

  validates :forum_id, presence: true
  validates :user_id,  presence: true
  validates :title,    presence: true, length: { minimum: 10 }
  validates :content,  presence: true, length: { minimum: 20 }

  scope :pinned_first, -> { order(pinned: :desc) }
  scope :latest,       -> { order('COALESCE(topics.last_commented_at, topics.created_at) DESC') }

  after_initialize do
    self.forum ||= Forum.uncategorized
  end

  before_save do
    self.cooked_content = ApplicationController.helpers.markdown(content) if content_changed?
  end

  def pin!
    self.pinned = true
    self.save!
  end

  def unpin!
    self.pinned = false
    self.save!
  end

  def lock!
    self.locked = true
    self.save!
  end

  def unlock!
    self.locked = false
    self.save!
  end

  def hide!
    self.hidden = true
    self.save!
  end

  def unhide!
    self.hidden = false
    self.save!
  end
end
