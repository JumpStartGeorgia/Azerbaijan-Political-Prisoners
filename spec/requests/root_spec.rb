require 'rails_helper'

RSpec.describe 'Root', type: :request do
  describe 'GET /csv_zip' do
    it 'works' do
      get csv_zip_path
      expect(response).to have_http_status(200)
    end
  end
end
