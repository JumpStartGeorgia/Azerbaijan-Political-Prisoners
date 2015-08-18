require 'rails_helper'

RSpec.describe 'Prisoners', type: :request do
  let(:prisoner1) { FactoryGirl.create(:prisoner, name: 'prisoner1') }
  let(:prisoner2) { FactoryGirl.create(:prisoner, name: 'prisoner2') }

  before(:example) do
    prisoner1.save!
    prisoner2.save!
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
        prisoner1.incidents << FactoryGirl.create(
          :incident,
          date_of_arrest: Date.today - 2.years,
          prison: prison1,
          articles: [article1, article2])

        get prisoners_path
      end

      it 'name' do
        expect(response.body).to include(prisoner1.name)
      end

      it 'day of arrest' do
        expect(response.body).to include(l prisoner1.incidents.first.date_of_arrest, format: :long)
      end

      it 'articles' do
        expect(response.body).to include(prisoner1.incidents.first.articles.first.number)
        expect(response.body).to include(prisoner1.incidents.first.articles.second.number)
      end

      it 'total days in prison' do
        expect(response.body).to include(prisoner1.total_days_in_prison.to_s)
      end

      it 'status' do
        expect(response.body).to include(prisoner1.currently_imprisoned_status)
      end
    end
  end

  describe 'GET prisoner' do
    it 'works with id' do
      get prisoner_path(prisoner1.id)

      expect(response).to have_http_status(301)
      expect(response).to redirect_to(
        prisoner_path(prisoner1))
      follow_redirect!

      expect(response).to have_http_status(200)
      expect(response.body).to include(prisoner1.name)
    end

    it 'works with friendly id' do
      get prisoner_path(prisoner1)
      expect(response).to have_http_status(200)
      expect(response.body).to include(prisoner1.name)
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
      expect(response.body).to include(prisoner1.name)
      expect(response.body).to include(prisoner2.name)
    end
  end

  it 'timeline json is different after adding incident to prisoner' do
    GeneratedFile.remove

    get imprisoned_count_timeline_prisoners_path
    orig_json = response.body

    incident1 = FactoryGirl.create(:incident, prisoner: prisoner1, date_of_arrest: 10.days.ago)
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
        get edit_prisoner_path(prisoner1.id)

        expect(response).to have_http_status(301)
        expect(response).to redirect_to(
          edit_prisoner_path(prisoner1))
        follow_redirect!

        expect(response).to have_http_status(200)
        expect(response.body).to include(prisoner1.name)
      end

      it 'works with friendly id' do
        get edit_prisoner_path(prisoner1.name)
        expect(response).to have_http_status(200)
        expect(response.body).to include(prisoner1.name)
      end
    end
  end
end
