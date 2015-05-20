require 'rails_helper'

RSpec.describe TagsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: tags_path).to route_to('tags#index', locale: 'en')
    end

    it 'routes to #new' do
      expect(get: new_tag_path).to route_to('tags#new', locale: 'en')
    end

    it 'routes to #show' do
      expect(get: tag_path(:en, 1)).to route_to('tags#show', id: '1', locale: 'en')
    end

    it 'routes to #edit' do
      expect(get: edit_tag_path(:en, 1)).to route_to('tags#edit', id: '1', locale: 'en')
    end

    it 'routes to #create' do
      expect(post: tags_path).to route_to('tags#create', locale: 'en')
    end

    it 'routes to #update' do
      expect(put: tag_path(:en, 1)).to route_to('tags#update', id: '1', locale: 'en')
    end

    it 'routes to #destroy' do
      expect(delete: tag_path(:en, 1)).to route_to('tags#destroy', id: '1', locale: 'en')
    end
  end
end
