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
# Indexes
#
#  index_topics_on_forum_id              (forum_id)
#  index_topics_on_last_commented_by_id  (last_commented_by_id)
#  index_topics_on_user_id               (user_id)
#

require 'spec_helper'

describe Topic do
  pending "add some examples to (or delete) #{__FILE__}"
end
