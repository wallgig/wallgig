# == Schema Information
#
# Table name: topics
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  title          :string(255)
#  content        :text
#  cooked_content :text
#  pinned         :boolean
#  locked         :boolean
#  hidden         :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  forum_id       :integer
#

require 'spec_helper'

describe Topic do
  pending "add some examples to (or delete) #{__FILE__}"
end
