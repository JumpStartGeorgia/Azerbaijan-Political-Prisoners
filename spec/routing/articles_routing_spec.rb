require 'rails_helper'

RSpec.describe ArticlesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: articles_path).to route_to('articles#index', locale: 'en')
    end

    it 'routes to #new' do
      expect(get: new_article_path).to route_to('articles#new', locale: 'en')
    end

    it 'routes to #show' do
      expect(get: article_path(:en, 1)).to route_to('articles#show', id: '1', locale: 'en')
    end

    it 'routes to #edit' do
      expect(get: edit_article_path(:en, 1)).to route_to('articles#edit', id: '1', locale: 'en')
    end

    it 'routes to #create' do
      expect(post: articles_path).to route_to('articles#create', locale: 'en')
    end

    it 'routes to #update' do
      expect(put: article_path(:en, 1)).to route_to('articles#update', id: '1', locale: 'en')
    end

    it 'routes to #destroy' do
      expect(delete: article_path(:en, 1)).to route_to('articles#destroy', id: '1', locale: 'en')
    end
  end
end
