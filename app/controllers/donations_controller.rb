class DonationsController < ApplicationController

  # GET /donations
  def index
    @donation_goal = DonationGoal.current
    @donations     = Donation.includes(:user).latest.limit(20)
  end
end
