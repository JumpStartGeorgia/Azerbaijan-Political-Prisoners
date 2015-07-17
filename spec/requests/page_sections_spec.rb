require 'rails_helper'

RSpec.describe "PageSections", type: :request do
  before(:context) do
    @role = FactoryGirl.create(:role, name: 'site_admin')
    @site_admin = FactoryGirl.create(:user, role: @role)
  end

  describe "GET /page_sections" do
    it "works" do
      login_as(@site_admin, scope: :user)

      get page_sections_path
      expect(response).to have_http_status(200)
    end
  end
end
