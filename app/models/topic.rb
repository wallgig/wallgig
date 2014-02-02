# == Schema Information
#
# Table name: topics
#
#  id             :integer          not null, primary key
#  owner_id       :integer
#  owner_type     :string(255)
#  user_id        :integer
#  title          :string(255)
#  content        :text
#  cooked_content :text
#  pinned         :boolean
#  locked         :boolean
#  hidden         :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

class Topic < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user

  acts_as_commentable

  include Reportable

  validates :owner,   presence: true
  validates :user,    presence: true
  validates :title,   presence: true, length: { minimum: 10 }
  validates :content, presence: true, length: { minimum: 20 }

  scope :pinned_first, -> { order(pinned: :desc) }
  scope :latest,       -> { order(updated_at: :desc) }

  before_save do
    self.cooked_content = ApplicationController.helpers.markdown(content) if content_changed?
  end

  def to_s
    title
  end

  def cooked_content
    read_attribute(:cooked_content).try(:html_safe)
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
