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

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :user, presence: true
  validates :notifiable, presence: true
  validates :message, presence: true

  scope :latest, -> { order(created_at: :desc) }
  scope :unread, -> { where(read: false) }

  def to_actual_model
    case notifiable_type
    when 'Subscription'
      notifiable.subscribable
    end
  end

  def self.mark_as_read
    update_all(read: true)
  end
end
