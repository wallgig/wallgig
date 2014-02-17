# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  notifiable_id   :integer
#  notifiable_type :string(255)
#  message         :text
#  read            :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Notification do
  pending "add some examples to (or delete) #{__FILE__}"
end
