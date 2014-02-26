# == Schema Information
#
# Table name: reports
#
#  id              :integer          not null, primary key
#  reportable_id   :integer
#  reportable_type :string(255)
#  user_id         :integer
#  description     :text
#  closed_by_id    :integer
#  closed_at       :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  reasons         :text
#
# Indexes
#
#  index_reports_on_closed_by_id                       (closed_by_id)
#  index_reports_on_reportable_id_and_reportable_type  (reportable_id,reportable_type)
#  index_reports_on_user_id                            (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report do
    reportable nil
    user nil
    description "MyText"
    closed_by nil
    closed_at "2014-01-17 06:07:09"
  end
end
