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

    describe 'displays prisoner attribute' do
      before(:example) do
        prison1 = FactoryGirl.create(:prison)
        article1 = FactoryGirl.create(:article)
        article2 = FactoryGirl.create(:article)
        p1 = Prisoner.find_by_name(prisoner_name_1)
        p1.incidents << FactoryGirl.create(
          :incident,
          date_of_arrest: Date.today - 2.years,
          prison: prison1,
          articles: [article1, article2])

        get prisoners_path
      end

      it 'name' do
        p1 = Prisoner.find_by_name(prisoner_name_1)
        expect(response.body).to include(p1.name)
      end

      it 'day of arrest' do
        p1 = Prisoner.find_by_name(prisoner_name_1)
        expect(response.body).to include(l p1.incidents.first.date_of_arrest, format: :long)
      end

      it 'articles' do
        p1 = Prisoner.find_by_name(prisoner_name_1)
        expect(response.body).to include(p1.incidents.first.articles.first.number)
        expect(response.body).to include(p1.incidents.first.articles.second.number)
      end

      it 'total days in prison' do
        p1 = Prisoner.find_by_name(prisoner_name_1)
        expect(response.body).to include(p1.total_days_in_prison.to_s)
      end

      it 'status' do
        p1 = Prisoner.find_by_name(prisoner_name_1)
        expect(response.body).to include(p1.currently_imprisoned_status)
      end
    end
  end

  describe 'GET prisoner' do
    it 'works with id' do
      get prisoner_path(Prisoner.find_by_name(prisoner_name_1).id)

      expect(response).to have_http_status(301)
      expect(response).to redirect_to(
        prisoner_path(Prisoner.find_by_name(prisoner_name_1)))
      follow_redirect!

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
    incident1 = FactoryGirl.create(:incident, prisoner: pris1, date_of_arrest: 10.days.ago)
    incident1.run_callbacks(:commit)

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
        get edit_prisoner_path(Prisoner.find_by_name(prisoner_name_1).id)

        expect(response).to have_http_status(301)
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
