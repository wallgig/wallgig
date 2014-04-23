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
#  bumped_at            :datetime
#
# Indexes
#
#  index_topics_on_forum_id              (forum_id)
#  index_topics_on_last_commented_by_id  (last_commented_by_id)
#  index_topics_on_user_id               (user_id)
#

class Topic < ActiveRecord::Base
  include Cookable
  cookable :content

  MODERATION_ACTIONS = [:pin, :unpin, :lock, :unlock, :hide, :unhide, :bump]

  belongs_to :forum
  belongs_to :user
  belongs_to :last_commented_by, class_name: 'User'

  has_paper_trail

  include Commentable

  include Reportable

  include PgSearch
  pg_search_scope :search_topics_and_comments, against: [:title, :content], associated_against: {
    comments: [:comment]
  }

  validates :forum_id, presence: true
  validates :user_id,  presence: true
  validates :title,    presence: true, length: { minimum: 10 }
  validates :content,  presence: true, length: { minimum: 20 }

  scope :pinned_first, -> { order(pinned: :desc) }
  scope :latest, -> {
    order("
      COALESCE(
        #{quoted_table_name}.bumped_at,
        #{quoted_table_name}.last_commented_at,
        #{quoted_table_name}.created_at
      ) DESC
    ")
  }

  after_initialize do
    self.forum ||= Forum.uncategorized
  end

  def to_s
    title
  end

  def cache_key
    if persisted? && (timestamp = self[:last_commented_at])
      timestamp = timestamp.utc.to_s(cache_timestamp_format)
      "#{super}-#{timestamp}"
    else
      "#{super}"
    end
  end

  def pin!
    update_attribute(:pinned, true)
  end

  def unpin!
    update_attribute(:pinned, false)
  end

  def lock!
    update_attribute(:locked, true)
  end

  def unlock!
    update_attribute(:locked, false)
  end

  def hide!
    update_attribute(:hidden, true)
  end

  def unhide!
    update_attribute(:hidden, false)
  end
end
