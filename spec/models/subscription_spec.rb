# == Schema Information
#
# Table name: subscriptions
#
#  id                             :integer          not null, primary key
#  user_id                        :integer
#  subscribable_id                :integer
#  subscribable_type              :string(255)
#  last_visited_at                :datetime
#  created_at                     :datetime
#  updated_at                     :datetime
#  subscriptions_wallpapers_count :integer          default(0)
#

require 'spec_helper'

describe Subscription do
  pending "add some examples to (or delete) #{__FILE__}"
end
