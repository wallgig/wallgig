require 'spec_helper'

describe "subscriptions/new" do
  before(:each) do
    assign(:subscription, stub_model(Subscription,
      :user => nil,
      :subscribable => nil
    ).as_new_record)
  end

  it "renders new subscription form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", subscriptions_path, "post" do
      assert_select "input#subscription_user[name=?]", "subscription[user]"
      assert_select "input#subscription_subscribable[name=?]", "subscription[subscribable]"
    end
  end
end
