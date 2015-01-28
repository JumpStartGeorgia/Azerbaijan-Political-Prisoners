require 'rails_helper'

RSpec.describe "The prisoner new page", :type => :feature do
  describe "with one added incident" do
    it "loads two TinyMCE editors", :js => true do
      visit '/prisoners/new'
      click_link 'Add New Incident'
      expect(page).to have_selector('.mce-tinymce', :count => 2)
    end

    it "loads two TinyMCE editors after failing to be created", :js => true do
      visit '/prisoners/new'
      click_link 'Add New Incident'
      click_button 'Create Prisoner'
      expect(page).to have_selector('.mce-tinymce', :count => 2)
    end
  end
end