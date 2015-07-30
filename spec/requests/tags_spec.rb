require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  let(:tag1) { FactoryGirl.create(:tag_with_description) }
  let(:tag2) { FactoryGirl.create(:tag_with_description) }

  describe 'GET /tags' do
    it 'works' do
      get tags_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET tag' do
    it 'works with id' do
      get tag_path(tag1.id)

      expect(response).to have_http_status(301)
      expect(response).to redirect_to(
        tag_path(tag1))
      follow_redirect!

      expect(response).to have_http_status(200)
      expect(response.body).to include(tag1.name)
    end

    it 'works with friendly id' do
      get tag_path(tag1)
      expect(response).to have_http_status(200)
      expect(response.body).to include(tag1.name)
    end
  end

  describe 'GET /tags.csv' do
    it 'works' do
      tag1.save!
      tag2.save!

      get tags_path(format: :csv)
      expect(response).to have_http_status(200)
      expect(response.body).to include(tag1.name)
      expect(response.body).to include(tag1.description)
      expect(response.body).to include(tag2.name)
      expect(response.body).to include(tag2.description)
    end
  end

  describe 'content manager user' do
    before(:example) do
      @role = FactoryGirl.create(:role, name: 'content_manager')
      @user = FactoryGirl.create(:user, role: @role)

      login_as(@user, scope: :user)
    end

    describe 'EDIT tag' do
      it 'works with id' do
        get edit_tag_path(tag1.id)

        expect(response).to have_http_status(301)
        expect(response).to redirect_to(
          edit_tag_path(tag1))
        follow_redirect!

        expect(response).to have_http_status(200)
        expect(response.body).to include(tag1.name)
      end

      it 'works with friendly id' do
        get edit_tag_path(tag1)
        expect(response).to have_http_status(200)
        expect(response.body).to include(tag1.name)
      end
    end
  end
end
