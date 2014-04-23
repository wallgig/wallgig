# == Schema Information
#
# Table name: user_settings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  sfw                  :boolean          default(TRUE), not null
#  sketchy              :boolean          default(FALSE), not null
#  nsfw                 :boolean          default(FALSE), not null
#  per_page             :integer          default(20)
#  infinite_scroll      :boolean          default(TRUE), not null
#  screen_width         :integer
#  screen_height        :integer
#  created_at           :datetime
#  updated_at           :datetime
#  screen_resolution_id :integer
#  invisible            :boolean          default(FALSE), not null
#  aspect_ratios        :text
#  resolution_exactness :string(255)      default("at_least")
#  new_window           :boolean          default(TRUE), not null
#
# Indexes
#
#  index_user_settings_on_screen_resolution_id  (screen_resolution_id)
#  index_user_settings_on_user_id               (user_id) UNIQUE
#

require 'spec_helper'

describe UserSetting do
  pending "add some examples to (or delete) #{__FILE__}"
end
