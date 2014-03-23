# == Schema Information
#
# Table name: donation_goals
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  starts_on :date             not null
#  ends_on   :date
#  cents     :integer          not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :donation_goal do
    name "MyString"
    starts_on "2014-03-23"
    ends_on "2014-03-23"
    cents 1
  end
end
