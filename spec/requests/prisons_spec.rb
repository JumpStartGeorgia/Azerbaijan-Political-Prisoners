require 'rails_helper'

RSpec.describe "Prisons", :type => :request do
  describe "GET /prisons" do
    it "works" do
      get prisons_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /prisoners/prison_prisoner_counts" do
    it "works" do
      get prison_prisoner_counts_prisons_path
      expect(response).to have_http_status(200)
    end
  end
end
