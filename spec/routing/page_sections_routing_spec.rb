require 'rails_helper'

RSpec.describe PageSectionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: page_sections_path).to route_to('page_sections#index', locale: :en)
    end

    it 'routes to #new' do
      expect(get: new_page_section_path).to route_to('page_sections#new', locale: :en)
    end

    it 'routes to #show' do
      expect(get: page_section_path(:en, 1)).to route_to('page_sections#show', id: '1', locale: :en)
    end

    it 'routes to #edit' do
      expect(get: edit_page_section_path(:en, 1)).to route_to('page_sections#edit', id: '1', locale: :en)
    end

    it 'routes to #create' do
      expect(post: '/page_sections').to route_to('page_sections#create', locale: :en)
    end

    it 'routes to #update' do
      expect(put: page_section_path(:en, 1)).to route_to('page_sections#update', id: '1', locale: :en)
    end

    it 'routes to #destroy' do
      expect(delete: page_section_path(:en, 1)).to route_to('page_sections#destroy', id: '1', locale: :en)
    end
  end
end
