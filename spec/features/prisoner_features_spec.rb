require 'rails_helper'

RSpec.describe "Prisoner", :type => :feature do
  before(:example) do
    @role = FactoryGirl.create(:role, name: 'user_manager')
    @user = FactoryGirl.create(:user, role: @role)
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

  it "can be created using new form and then updated using edit form", js: true do
    Rails.logger.debug('failing test!')
    login_as(@user, scope: :user)

    visit new_prisoner_path
    within('.inputs') do
      fill_in 'Name', :with => 'Bob Jones'
    end

    click_link 'Add New Incident'
    within('.nested-fields') do
      fill_in 'Date of arrest', :with => '02/09/2015'
    end

    click_button 'Create Prisoner'
    expect(page).to have_content('Prisoner was successfully created.')

  end
end