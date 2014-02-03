# == Schema Information
#
# Table name: topics
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  title          :string(255)
#  content        :text
#  cooked_content :text
#  pinned         :boolean          default(FALSE)
#  locked         :boolean          default(FALSE)
#  hidden         :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#  forum_id       :integer
#  comments_count :integer          default(0)
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
