# == Schema Information
#
# Table name: donation_goals
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  starts_on :date             not null
#  ends_on   :date
#  cents     :integer          not null
#

require 'spec_helper'

describe DonationGoal do
  pending "add some examples to (or delete) #{__FILE__}"
end
