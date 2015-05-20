require 'rails_helper'

RSpec.describe PrisonsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: prisons_path).to route_to('prisons#index')
    end

    it 'routes to #new' do
      expect(get: new_prison_path).to route_to('prisons#new')
    end

    it 'routes to #show' do
      expect(get: prison_path(1)).to route_to('prisons#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: edit_prison_path(1)).to route_to('prisons#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: prisons_path).to route_to('prisons#create')
    end

    it 'routes to #update' do
      expect(put: prison_path(1)).to route_to('prisons#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: prison_path(1)).to route_to('prisons#destroy', id: '1')
    end
  end
end
