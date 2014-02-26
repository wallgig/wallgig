# == Schema Information
#
# Table name: forums
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  description :text
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  color       :string(255)
#  text_color  :string(255)
#  can_read    :boolean          default(TRUE)
#  can_post    :boolean          default(TRUE)
#  can_comment :boolean          default(TRUE)
#
# Indexes
#
#  index_forums_on_slug  (slug)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :forum do
    group nil
    name "MyString"
    slug "MyString"
    description "MyText"
    position 1
  end
end
