# == Schema Information
#
# Table name: subscriptions
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  subscribable_id   :integer
#  subscribable_type :string(255)
#  last_visited_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribable, polymorphic: true

  validates :user_id, presence: true, uniqueness: { scope: [:subscribable_id, :subscribable_type] }

  before_create do
    self.last_visited_at = Time.now
  end

  scope :by_type, -> (type) { where(subscribable_type: type) }

  def self.mark_all_as_read!
    update_all(last_visited_at: Time.now)
  end

  def mark_all_as_read!
    update_attribute(:last_visited_at, Time.now)
  end
end
