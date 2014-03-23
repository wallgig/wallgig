class AddDonationGoalToDonations < ActiveRecord::Migration
  def change
    add_reference :donations, :donation_goal, index: true
  end
end
