# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  notifiable_id   :integer
#  notifiable_type :string(255)
#  message         :text
#  read            :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_notifications_on_notifiable_id_and_notifiable_type  (notifiable_id,notifiable_type)
#  index_notifications_on_read                               (read)
#  index_notifications_on_user_id                            (user_id)
#

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :user, presence: true
  validates :message, presence: true

  scope :latest, -> { order(created_at: :desc) }
  scope :read,   -> { where(read: true) }
  scope :unread, -> { where(read: false) }

  def self.mark_as_read
    update_all(read: true)
  end

  def to_actual_model
    case notifiable_type
    when 'Comment'
      notifiable.commentable
    when 'Subscription'
      notifiable.user
    end
  end

  def mark_as_read
    update_attribute(:read, true)
  end
end
