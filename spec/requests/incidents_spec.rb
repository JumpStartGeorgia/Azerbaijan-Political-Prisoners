require 'rails_helper'

RSpec.describe 'Incidents', type: :request do
  prisoner_name_1 = 'Bobby'
  date_arrest_1 = '2013-11-22'
  description_arrest_1 = 'description_arrest_1'
  tag_name_1 = 'tag_1'
  tag_name_2 = 'tag_2'
  article_number_1 = '12.34'
  article_number_2 = '123.456'
  prison_name_1 = 'prison_1'
  date_release_1 = '2014-05-14'
  description_release_1 = 'description_release_1'

  before(:example) do
    prisoner_1 = FactoryGirl.create(:prisoner, name: prisoner_name_1)
    tag_1 = FactoryGirl.create(:tag, name: tag_name_1)
    tag_2 = FactoryGirl.create(:tag, name: tag_name_2)
    article_1 = FactoryGirl.create(:article, number: article_number_1)
    article_2 = FactoryGirl.create(:article, number: article_number_2)
    prison_1 = FactoryGirl.create(:prison, name: prison_name_1)

    FactoryGirl.create(:incident,
                       prisoner: prisoner_1,
                       date_of_arrest: date_arrest_1,
                       description_of_arrest: description_arrest_1,
                       tags: [tag_1, tag_2],
                       articles: [article_1, article_2],
                       prison: prison_1,
                       date_of_release: date_release_1,
                       description_of_release: description_release_1
                      )
  end

  describe 'GET /prisoners/incidents_to_csv' do
    it 'works' do
      get '/prisoners/incidents_to_csv'
      expect(response).to have_http_status(200)

      [
        prisoner_name_1,
        date_arrest_1,
        description_arrest_1,
        prison_name_1,
        date_release_1,
        description_release_1
      ].each do |content|
        expect(response.body).to include(content)
      end

      expect(response.body).to include(tag_name_1 + ', ' + tag_name_2)
      expect(response.body).to include(article_number_1 + ', ' + article_number_2)
    end
  end
end
