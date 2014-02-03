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

  has_paper_trail

  include Reportable

  belongs_to :commentable, polymorphic: true, counter_cache: true

  scope :latest, -> { reorder('created_at DESC') }
  default_scope -> { order('created_at ASC') }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  belongs_to :user

  validates :comment, presence: true, length: { minimum: 20 }

  before_save do
    self.cooked_comment = self.class.markdown.render(comment)
  end

  after_create  :update_last_comment_on_create
  after_destroy :update_last_comment_on_destroy

  def self.markdown
    @markdown ||= begin
      renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
      Redcarpet::Markdown.new(renderer, space_after_headers: true)
    end
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
end
