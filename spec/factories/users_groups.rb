# == Schema Information
#
# Table name: users_groups
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  group_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  role       :string(255)
#
# Indexes
#
#  index_users_groups_on_group_id  (group_id)
#  index_users_groups_on_role      (role)
#  index_users_groups_on_user_id   (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_group do
    user nil
    group nil
    role 1
  end
end
