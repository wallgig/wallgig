# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  owner_id    :integer
#  name        :string(255)
#  slug        :string(255)
#  description :text
#  has_forums  :boolean
#  created_at  :datetime
#  updated_at  :datetime
#  tagline     :string(255)
#  access      :string(255)
#  official    :boolean          default(FALSE)
#  internal    :boolean          default(FALSE)
#  color       :string(255)
#  text_color  :string(255)
#  position    :integer
#
# Indexes
#
#  index_groups_on_access    (access)
#  index_groups_on_owner_id  (owner_id)
#  index_groups_on_slug      (slug) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    owner nil
    name "MyString"
    slug "MyString"
    description "MyText"
    public false
    admin_title "MyString"
    moderator_title "MyString"
    member_title "MyString"
    has_forums false
  end
end
