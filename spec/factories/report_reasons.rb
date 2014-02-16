# == Schema Information
#
# Table name: report_reasons
#
#  id              :integer          not null, primary key
#  reportable_type :string(255)
#  reason          :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_reason do
    reportable_type "MyString"
    reason "MyString"
  end
end
