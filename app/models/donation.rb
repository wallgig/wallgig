# == Schema Information
#
# Table name: donations
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  email            :string(255)
#  currency         :string(3)        not null
#  cents            :integer          not null
#  base_cents       :integer          not null
#  anonymous        :boolean          default(TRUE), not null
#  donated_at       :datetime
#  donation_goal_id :integer
#
# Indexes
#
#  index_donations_on_donation_goal_id  (donation_goal_id)
#  index_donations_on_user_id           (user_id)
#

class Donation < ActiveRecord::Base
  belongs_to :user
  belongs_to :donation_goal

  validates :currency, presence: true
  validates :cents, presence: true
  validates :base_cents, presence: true

  scope :latest, -> { order(donated_at: :desc) }

  before_save do
    self.donation_goal ||= DonationGoal.current
    self.base_cents    ||= cents
  end

  def amount
    cents / 100.0
  end
end
