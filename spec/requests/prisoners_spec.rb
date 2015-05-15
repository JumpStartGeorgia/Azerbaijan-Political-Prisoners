require 'rails_helper'

RSpec.describe 'Prisoners', type: :request do
  prisoner_name_1 = 'Prisoner#1'
  prisoner_name_2 = 'Prisoner#2'

  before(:example) do
    FactoryGirl.create(:prisoner, name: prisoner_name_1)
    FactoryGirl.create(:prisoner, name: prisoner_name_2)
  end

  describe 'GET /prisoners' do
    it 'works' do
      get prisoners_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /prisoners/imprisoned_count_timeline' do
    it 'works' do
      get imprisoned_count_timeline_prisoners_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /prisoners.csv' do
    it 'works' do
      get '/prisoners.csv'
      expect(response).to have_http_status(200)
      expect(response.body).to include(prisoner_name_1)
      expect(response.body).to include(prisoner_name_2)
    end
  end
end
