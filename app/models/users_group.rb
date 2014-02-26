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

class UsersGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  extend Enumerize
  enumerize :role, in: [:admin, :moderator, :banned], scope: true, predicates: true

  validates :user_id,  presence: true, uniqueness: { scope: [:group_id], message: 'already joined this group' }
  validates :group_id, presence: true

  scope :officers, -> { where(role: ['admin', 'moderator']).order(role: :asc) }
end
