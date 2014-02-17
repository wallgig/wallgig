# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  title            :string(50)       default("")
#  comment          :text
#  commentable_id   :integer
#  commentable_type :string(255)
#  user_id          :integer
#  role             :string(255)      default("comments")
#  created_at       :datetime
#  updated_at       :datetime
#  cooked_comment   :text
#

class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true

  include Notifiable

  include Reportable

  has_paper_trail

  validates :user,        presence: true
  validates :commentable, presence: true
  validates :comment,     presence: true, length: { minimum: 10 }

  scope :latest, -> { reorder('created_at DESC') }
  default_scope  -> { order('created_at ASC') }

  before_save do
    self.cooked_comment = ApplicationController.helpers.markdown(comment) if comment_changed?
  end

  after_create :update_last_comment_on_create
  after_create :notify

  after_destroy :update_last_comment_on_destroy

  def to_s
    "Comment \##{id}"
  end

  def update_last_comment_on_create
    if commentable_type == 'Topic'
      self.commentable.update_columns last_commented_at: created_at, last_commented_by_id: user_id
    end
  end

  def update_last_comment_on_destroy
    if commentable_type == 'Topic'
      self.commentable.comments.last.update_last_comment_on_create
    end
  end

  def notify
    case commentable_type
    when 'Wallpaper'
      # Make sure we're not receiving notifications on our own comments
      if user_id != commentable.user_id
        notifications.create({
          user_id: commentable.user_id,
          message: I18n.t('comments.notifications.wallpaper.message', username: user.username, id: commentable_id)
        })
      end

      # TODO detect mentions and notify them
    end
  end
end
