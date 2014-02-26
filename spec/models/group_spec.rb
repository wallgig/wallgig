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

require 'spec_helper'

describe Group do
  pending "add some examples to (or delete) #{__FILE__}"
end
