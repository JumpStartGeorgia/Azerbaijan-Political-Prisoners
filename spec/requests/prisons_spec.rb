require 'rails_helper'

RSpec.describe "Prisons", :type => :request do
  describe "GET /prisons" do
    it "works! (now write some real specs)" do
      get prisons_path
      expect(response).to have_http_status(200)
    end
  end
end
