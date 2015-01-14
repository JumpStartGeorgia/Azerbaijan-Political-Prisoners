require "rails_helper"

RSpec.describe SubtypesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/subtypes").to route_to("subtypes#index")
    end

    it "routes to #new" do
      expect(:get => "/subtypes/new").to route_to("subtypes#new")
    end

    it "routes to #show" do
      expect(:get => "/subtypes/1").to route_to("subtypes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/subtypes/1/edit").to route_to("subtypes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/subtypes").to route_to("subtypes#create")
    end

    it "routes to #update" do
      expect(:put => "/subtypes/1").to route_to("subtypes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/subtypes/1").to route_to("subtypes#destroy", :id => "1")
    end

  end
end
