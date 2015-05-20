require 'rails_helper'

RSpec.describe PrisonersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: prisoners_path).to route_to('prisoners#index', locale: 'en')
    end

    it 'routes to #new' do
      expect(get: new_prisoner_path).to route_to('prisoners#new', locale: 'en')
    end

    it 'routes to #show' do
      expect(get: prisoner_path(:en, 1)).to route_to('prisoners#show', id: '1', locale: 'en')
    end

    it 'routes to #edit' do
      expect(get: edit_prisoner_path(:en, 1)).to route_to('prisoners#edit', id: '1', locale: 'en')
    end

    it 'routes to #create' do
      expect(post: prisoners_path).to route_to('prisoners#create', locale: 'en')
    end

    it 'routes to #update' do
      expect(put: prisoner_path(:en, 1)).to route_to('prisoners#update', id: '1', locale: 'en')
    end

    it 'routes to #destroy' do
      expect(delete: prisoner_path(:en, 1)).to route_to('prisoners#destroy', id: '1', locale: 'en')
    end
  end
end
