require 'rails_helper'

RSpec.describe "CriminalCodes", :type => :request do
  describe "GET /criminal_codes" do
    it "works! (now write some real specs)" do
      get criminal_codes_path
      expect(response).to have_http_status(200)
    end
  end
end
