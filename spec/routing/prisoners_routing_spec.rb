require 'rails_helper'

RSpec.describe PrisonersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: prisoners_path).to route_to('prisoners#index')
    end

    it 'routes to #new' do
      expect(get: new_prisoner_path).to route_to('prisoners#new')
    end

    it 'routes to #show' do
      expect(get: prisoner_path(1)).to route_to('prisoners#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: edit_prisoner_path(1)).to route_to('prisoners#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: prisoners_path).to route_to('prisoners#create')
    end

    it 'routes to #update' do
      expect(put: prisoner_path(1)).to route_to('prisoners#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: prisoner_path(1)).to route_to('prisoners#destroy', id: '1')
    end
  end
end
