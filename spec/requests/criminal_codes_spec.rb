require 'rails_helper'

RSpec.describe 'CriminalCodes', type: :request do
  let(:criminal_code) { FactoryGirl.create(:criminal_code, name: 'Current') }

  describe 'GET /criminal_codes' do
    it 'works' do
      get criminal_codes_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /criminal_codes.csv' do
    it 'works' do
      get criminal_codes_path(format: :csv)
      expect(response).to have_http_status(200)
    end

    it 'includes the name of saved criminal code' do
      criminal_code.save!
      get criminal_codes_path(format: :csv)
      expect(response.body).to include(criminal_code.name)
    end
  end
end
