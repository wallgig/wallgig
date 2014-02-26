# == Schema Information
#
# Table name: user_settings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  sfw                  :boolean          default(TRUE)
#  sketchy              :boolean          default(FALSE)
#  nsfw                 :boolean          default(FALSE)
#  per_page             :integer          default(20)
#  infinite_scroll      :boolean          default(TRUE)
#  screen_width         :integer
#  screen_height        :integer
#  created_at           :datetime
#  updated_at           :datetime
#  screen_resolution_id :integer
#  invisible            :boolean          default(FALSE)
#  aspect_ratios        :text
#  resolution_exactness :string(255)      default("at_least")
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
