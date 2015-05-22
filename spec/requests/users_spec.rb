require 'rails_helper'

RSpec.describe "Users", :type => :request do
  before(:context) do
    @role = FactoryGirl.create(:role, name: 'content_manager')
    @user = FactoryGirl.create(:user, role: @role)
  end

  describe "GET /users" do
    it "works! (now write some real specs)" do
      login_as(@user, scope: :user)

      get users_path
      expect(response).to have_http_status(200)
    end
  end
end
