class DonationsController < ApplicationController
  before_action :authenticate_user!, only: [:toggle_anonymous]

  # GET /donations
  def index
    @donation_goal = DonationGoal.current
    @donations     = Donation.includes(:user).latest.limit(20)
  end

  # PATCH /donations/1/toggle_anonymous
  def toggle_anonymous
    @donation = current_user.donations.find(params[:id])
    @donation.toggle!(:anonymous)

    if @donation.anonymous?
      redirect_to donations_path, notice: 'Donation was successfully anonymized.'
    else
      redirect_to donations_path, notice: 'Donation was successfully publicized.'
    end
  end
end
