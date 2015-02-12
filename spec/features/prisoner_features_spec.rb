require 'rails_helper'

RSpec.describe "Prisoner new view", :type => :feature do
  before(:context) do
    @role = FactoryGirl.create(:role, name: 'user_manager')
    @user = FactoryGirl.create(:user, email: "a@a.com", password: "12345678", role: @role)
  end

  describe "with one added incident" do
    it "loads two TinyMCE editors", :js => true do
      login_as(@user, scope: :user)

      visit '/prisoners/new'
      click_link 'Add New Incident'
      expect(page).to have_selector('.mce-tinymce', :count => 2)
    end

    it "loads two TinyMCE editors after failing to be created", :js => true do
      login_as(@user, scope: :user)

      visit '/prisoners/new'
      click_link 'Add New Incident'
      click_button 'Create Prisoner'
      expect(page).to have_selector('.mce-tinymce', :count => 2)
    end
  end
end