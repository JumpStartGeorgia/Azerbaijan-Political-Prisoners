require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  describe 'GET /articles' do
    it 'works' do
      get articles_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /articles/article_incident_counts' do
    it 'works' do
      get article_incident_counts_articles_path
      expect(response).to have_http_status(200)
    end
  end
end
