require "rails_helper"

RSpec.describe CriminalCodesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/criminal_codes").to route_to("criminal_codes#index")
    end

    it "routes to #new" do
      expect(:get => "/criminal_codes/new").to route_to("criminal_codes#new")
    end

    it "routes to #show" do
      expect(:get => "/criminal_codes/1").to route_to("criminal_codes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/criminal_codes/1/edit").to route_to("criminal_codes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/criminal_codes").to route_to("criminal_codes#create")
    end

    it "routes to #update" do
      expect(:put => "/criminal_codes/1").to route_to("criminal_codes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/criminal_codes/1").to route_to("criminal_codes#destroy", :id => "1")
    end

  end
end
