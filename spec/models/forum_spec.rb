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

require 'spec_helper'

describe Forum do
  pending "add some examples to (or delete) #{__FILE__}"
end
