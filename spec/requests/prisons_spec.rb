require 'rails_helper'

RSpec.describe 'Prisons', type: :request do
  prison_name_1 = 'prison_1'
  prison_description_1 = 'description_1'
  prison_name_2 = 'prison_2'
  prison_description_2 = 'description_2'

  before(:example) do
    FactoryGirl.create(:prison, name: prison_name_1, description: prison_description_1)
    FactoryGirl.create(:prison, name: prison_name_2, description: prison_description_2)
  end

  describe 'GET /prisons' do
    it 'works' do
      get prisons_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /prisoners/prison_prisoner_counts' do
    it 'works' do
      get prison_prisoner_counts_prisons_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /prisons.csv' do
    it 'works' do
      get prisons_path(format: :csv)
      expect(response).to have_http_status(200)
      expect(response.body).to include(prison_name_1)
      expect(response.body).to include(prison_description_1)
      expect(response.body).to include(prison_name_2)
      expect(response.body).to include(prison_description_2)
    end
  end

  it 'prisoner count json is different after adding prisoner to prison' do
    FileUtils.rm_rf(Rails.public_path.join('system',
                                           'json',
                                           'prison_prisoner_count_chart.json'))

    get prison_prisoner_counts_prisons_path
    orig_json = response.body

    prison1 = Prison.find_by_name(prison_name_1)
    prisoner1 = FactoryGirl.create(:prisoner)
    prisoner1.incidents <<
      FactoryGirl.create(:incident, prison: prison1)
    prisoner1.save!
    prisoner1.run_callbacks(:commit)

    get prison_prisoner_counts_prisons_path
    expect(orig_json).not_to eq(response.body)
  end
end
