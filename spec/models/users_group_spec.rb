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

require 'spec_helper'

describe UsersGroup do
  pending "add some examples to (or delete) #{__FILE__}"
end
