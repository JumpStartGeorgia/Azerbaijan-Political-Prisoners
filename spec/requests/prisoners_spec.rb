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

  describe 'GET prisoner' do
    it 'works with id' do
      get prisoner_path(Prisoner.find_by_name(prisoner_name_1).id)
      expect(response).to have_http_status(200)
      expect(response.body).to include(prisoner_name_1)
    end

    it 'works with friendly id' do
      get prisoner_path(Prisoner.find_by_name(prisoner_name_1))
      expect(response).to have_http_status(200)
      expect(response.body).to include(prisoner_name_1)
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
      get prisoners_path(format: :csv)
      expect(response).to have_http_status(200)
      expect(response.body).to include(prisoner_name_1)
      expect(response.body).to include(prisoner_name_2)
    end
  end

  it 'timeline json is different after adding incident to prisoner' do
    FileUtils.rm_rf(Rails.public_path.join('system',
                                           'json',
                                           'imprisoned_count_timeline.json'))

    get imprisoned_count_timeline_prisoners_path
    orig_json = response.body

    pris1 = Prisoner.find_by_name(prisoner_name_1)
    pris1.incidents <<
      FactoryGirl.create(:incident, date_of_arrest: 10.days.ago)
    pris1.save!
    pris1.run_callbacks(:commit)

    get imprisoned_count_timeline_prisoners_path
    expect(orig_json).not_to eq(response.body)
  end

  describe 'content manager user' do
    before(:example) do
      @role = FactoryGirl.create(:role, name: 'content_manager')
      @user = FactoryGirl.create(:user, role: @role)

      login_as(@user, scope: :user)
    end

    describe 'EDIT prisoner' do
      it 'works with id' do
        host! 'localhost'
        get edit_prisoner_path(Prisoner.find_by_name(prisoner_name_1).id)

        expect(response).to redirect_to(
          edit_prisoner_path(Prisoner.find_by_name(prisoner_name_1)))
        follow_redirect!

        expect(response).to have_http_status(200)
        expect(response.body).to include(prisoner_name_1)
      end

      it 'works with friendly id' do
        get edit_prisoner_path(Prisoner.find_by_name(prisoner_name_1))
        expect(response).to have_http_status(200)
        expect(response.body).to include(prisoner_name_1)
      end
    end
  end
end
