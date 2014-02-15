require "spec_helper"

describe SubscriptionsController do
  describe "routing" do

    it "routes to #index" do
      get("/subscriptions").should route_to("subscriptions#index")
    end

    it "routes to #new" do
      get("/subscriptions/new").should route_to("subscriptions#new")
    end

    it "routes to #show" do
      get("/subscriptions/1").should route_to("subscriptions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/subscriptions/1/edit").should route_to("subscriptions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/subscriptions").should route_to("subscriptions#create")
    end

    it "routes to #update" do
      put("/subscriptions/1").should route_to("subscriptions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/subscriptions/1").should route_to("subscriptions#destroy", :id => "1")
    end

  end
end
