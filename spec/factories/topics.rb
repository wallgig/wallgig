# == Schema Information
#
# Table name: topics
#
#  id             :integer          not null, primary key
#  owner_id       :integer
#  owner_type     :string(255)
#  user_id        :integer
#  title          :string(255)
#  content        :text
#  cooked_content :text
#  pinned         :boolean
#  locked         :boolean
#  hidden         :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :topic do
    owner nil
    user nil
    title "MyString"
    content "MyText"
    cooked_content "MyText"
    pinned false
    locked false
    hidden false
  end
end
