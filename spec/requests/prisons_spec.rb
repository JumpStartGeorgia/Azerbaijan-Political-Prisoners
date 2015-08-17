require 'rails_helper'

RSpec.describe 'Prisons', type: :request do
  prison_name_1 = 'prison_1'
  prison_description_1 = 'description_1'
  prison_name_2 = 'prison_2'
  prison_description_2 = 'description_2'

  let(:prison1) { FactoryGirl.create(:prison, name: prison_name_1, description: prison_description_1) }
  let(:prison2) { FactoryGirl.create(:prison, name: prison_name_2, description: prison_description_2) }

  describe 'GET /prisons' do
    it 'works' do
      get prisons_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET prison' do
    it 'works with id' do
      get prison_path(prison1.id)

      expect(response).to have_http_status(301)
      expect(response).to redirect_to(
        prison_path(prison1))
      follow_redirect!

      expect(response).to have_http_status(200)
      expect(response.body).to include(prison_name_1)
    end

    it 'works with friendly id' do
      get prison_path(prison1)
      expect(response).to have_http_status(200)
      expect(response.body).to include(prison_name_1)
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
      prison1.save!
      prison2.save!

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

    prisoner1 = FactoryGirl.create(:prisoner)
    incident1 = FactoryGirl.create(:incident, prisoner: prisoner1, prison: prison1)
    incident1.run_callbacks(:commit)

    get prison_prisoner_counts_prisons_path
    expect(orig_json).not_to eq(response.body)
  end

  describe 'content manager user' do
    before(:example) do
      @role = FactoryGirl.create(:role, name: 'content_manager')
      @user = FactoryGirl.create(:user, role: @role)

      login_as(@user, scope: :user)
    end

    describe 'EDIT prison' do
      it 'works with id' do
        get edit_prison_path(prison1.id)

        expect(response).to have_http_status(301)
        expect(response).to redirect_to(
          edit_prison_path(prison1))
        follow_redirect!

        expect(response).to have_http_status(200)
        expect(response.body).to include(prison_name_1)
      end

      it 'works with friendly id' do
        get edit_prison_path(prison1)
        expect(response).to have_http_status(200)
        expect(response.body).to include(prison_name_1)
      end
    end
  end
end
