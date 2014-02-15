require 'spec_helper'

describe "subscriptions/show" do
  before(:each) do
    @subscription = assign(:subscription, stub_model(Subscription,
      :user => nil,
      :subscribable => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
  end
end
