require 'rails_helper'

RSpec.describe CriminalCodesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: criminal_codes_path).to route_to('criminal_codes#index', locale: 'en')
    end

    it 'routes to #new' do
      expect(get: new_criminal_code_path).to route_to('criminal_codes#new', locale: 'en')
    end

    it 'routes to #show' do
      expect(get: criminal_code_path(:en, 1)).to route_to('criminal_codes#show', id: '1', locale: 'en')
    end

    it 'routes to #edit' do
      expect(get: edit_criminal_code_path(:en, 1)).to route_to('criminal_codes#edit', id: '1', locale: 'en')
    end

    it 'routes to #create' do
      expect(post: criminal_codes_path).to route_to('criminal_codes#create', locale: 'en')
    end

    it 'routes to #update' do
      expect(put: criminal_code_path(:en, 1)).to route_to('criminal_codes#update', id: '1', locale: 'en')
    end

    it 'routes to #destroy' do
      expect(delete: criminal_code_path(:en, 1)).to route_to('criminal_codes#destroy', id: '1', locale: 'en')
    end
  end
end
