# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  notifiable_id   :integer
#  notifiable_type :string(255)
#  message         :text
#  read            :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :user_id, presence: true
  validates :notifiable, presence: true
  validates :message, presence: true
end
