# == Schema Information
#
# Table name: topics
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  title                :string(255)
#  content              :text
#  cooked_content       :text
#  pinned               :boolean          default(FALSE)
#  locked               :boolean          default(FALSE)
#  hidden               :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  forum_id             :integer
#  comments_count       :integer          default(0)
#  last_commented_at    :datetime
#  last_commented_by_id :integer
#

require 'spec_helper'

describe Topic do
  pending "add some examples to (or delete) #{__FILE__}"
end
