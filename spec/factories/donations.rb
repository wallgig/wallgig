# == Schema Information
#
# Table name: donations
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  email            :string(255)
#  currency         :string(3)        default("USD"), not null
#  cents            :integer          not null
#  base_cents       :integer          not null
#  anonymous        :boolean          default(FALSE), not null
#  donated_at       :datetime
#  donation_goal_id :integer
#
# Indexes
#
#  index_donations_on_donation_goal_id  (donation_goal_id)
#  index_donations_on_user_id           (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :donation do
    user nil
    currency "MyString"
    cents 1
    anonymous false
  end
end
