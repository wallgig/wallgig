# == Schema Information
#
# Table name: subscriptions
#
#  id                                     :integer          not null, primary key
#  user_id                                :integer
#  subscribable_id                        :integer
#  subscribable_type                      :string(255)
#  last_visited_at                        :datetime
#  created_at                             :datetime
#  updated_at                             :datetime
#  sfw_subscriptions_wallpapers_count     :integer          default(0), not null
#  sketchy_subscriptions_wallpapers_count :integer          default(0), not null
#  nsfw_subscriptions_wallpapers_count    :integer          default(0), not null
#
# Indexes
#
#  index_subscriptions_on_subscribable_id_and_subscribable_type  (subscribable_id,subscribable_type)
#  index_subscriptions_on_user_id                                (user_id)
#

require 'spec_helper'

describe Subscription do
  pending "add some examples to (or delete) #{__FILE__}"
end
