require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  tag_name_1 = 'tag_1'
  tag_description_1 = 'description_1'
  tag_name_2 = 'tag_2'
  tag_description_2 = 'description_2'

  before(:example) do
    FactoryGirl.create(:tag, name: tag_name_1, description: tag_description_1)
    FactoryGirl.create(:tag, name: tag_name_2, description: tag_description_2)
  end

  describe 'GET /tags' do
    it 'works' do
      get tags_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET tag' do
    it 'works with id' do
      get tag_path(Tag.find_by_name(tag_name_1).id)
      expect(response).to have_http_status(200)
      expect(response.body).to include(tag_name_1)
    end

    it 'works with friendly id' do
      get tag_path(Tag.find_by_name(tag_name_1))
      expect(response).to have_http_status(200)
      expect(response.body).to include(tag_name_1)
    end
  end

  describe 'GET /tags.csv' do
    it 'works' do
      get tags_path(format: :csv)
      expect(response).to have_http_status(200)
      expect(response.body).to include(tag_name_1)
      expect(response.body).to include(tag_description_1)
      expect(response.body).to include(tag_name_2)
      expect(response.body).to include(tag_description_2)
    end
  end
end
