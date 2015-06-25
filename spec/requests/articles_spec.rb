require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  article_number_1 = '12.34'
  article_description_1 = 'description_1'
  article_number_2 = '45.67.888'
  article_description_2 = 'description_2'

  before(:example) do
    FactoryGirl.create(:article, number: article_number_1, description: article_description_1)
    FactoryGirl.create(:article, number: article_number_2, description: article_description_2)
  end

  describe 'GET /articles' do
    it 'works' do
      get articles_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET article' do
    it 'works with id' do
      get article_path(Article.find_by_number(article_number_1).id)
      expect(response).to have_http_status(200)
      expect(response.body).to include(article_number_1)
    end

    it 'works with friendly id' do
      get article_path(Article.find_by_number(article_number_1))
      expect(response).to have_http_status(200)
      expect(response.body).to include(article_number_1)
    end
  end

  describe 'GET /articles/article_incident_counts' do
    it 'works' do
      get article_incident_counts_articles_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /articles.csv' do
    it 'works' do
      get articles_path(format: :csv)
      expect(response).to have_http_status(200)
      expect(response.body).to include(article_number_1)
      expect(response.body).to include(article_description_1)
      expect(response.body).to include(article_number_2)
      expect(response.body).to include(article_description_2)
    end
  end

  it 'sentence count json is different after adding new sentence to prisoner' do
    FileUtils.rm_rf(Rails.public_path.join('system',
                                           'json',
                                           'article_incident_counts_chart.json'))

    get article_incident_counts_articles_path
    orig_json = response.body

    prisoner1 = FactoryGirl.create(:prisoner)
    prisoner1.incidents <<
      FactoryGirl.create(:incident, articles: [Article.find_by_number(article_number_1)])
    prisoner1.save!
    prisoner1.run_callbacks(:commit)

    get article_incident_counts_articles_path
    expect(orig_json).not_to eq(response.body)
  end
end
