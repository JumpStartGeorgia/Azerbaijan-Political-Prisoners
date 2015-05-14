require 'rails_helper'

RSpec.describe "Prisoners", :type => :request do
  describe "GET /prisoners" do
    it "works" do
      get prisoners_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /prisoners/imprisoned_count_timeline" do
    it "works" do
      get imprisoned_count_timeline_prisoners_path
      expect(response).to have_http_status(200)
    end
  end
end
