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
# Indexes
#
#  index_comments_on_commentable_id    (commentable_id)
#  index_comments_on_commentable_type  (commentable_type)
#  index_comments_on_user_id           (user_id)
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true

  include Notifiable

  include Reportable

  has_paper_trail

  validates :user,        presence: true
  validates :commentable, presence: true
  validates :comment,     presence: true, length: { minimum: 10 }

  scope :latest, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }

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
      commentable.update_columns last_commented_at: created_at, last_commented_by_id: user_id
    end
  end

  def update_last_comment_on_destroy
    if commentable_type == 'Topic'
      if last_comment = commentable.comments.last
        last_comment.update_last_comment_on_create
      else
        commentable.update_columns last_commented_at: nil, last_commented_by_id: nil
      end
    end
  end

  def notify
    case commentable_type
    when 'User'
      if user_id != commentable_id
        notifications.create({
          user_id: commentable_id,
          message: I18n.t('comments.notifications.user.message', username: user.username)
        })
      end

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

  # FIXME Strange bug that loads incorrect user when accessing via user's comments: `User.first.comments.first.user`
  def user
    User.find(user_id)
  end
end
