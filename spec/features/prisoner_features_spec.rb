require 'rails_helper'

RSpec.describe "Prisoner", :type => :feature do
  before(:example) do
    @role = FactoryGirl.create(:role, name: 'content_manager')
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
    FactoryGirl.create(:prison, name: 'prison#1')
    FactoryGirl.create(:article, number: 'article#1')
    FactoryGirl.create(:article, number: 'article#2')
    FactoryGirl.create(:tag, name: 'tag#1')
    FactoryGirl.create(:tag, name: 'tag#2')

    login_as(@user, scope: :user)

    visit new_prisoner_path
    within('.inputs') do
      fill_in 'Name', :with => 'Bob Jones'
    end

    click_link 'Add New Incident'
    within('.nested-fields') do
      fill_in 'Date of arrest', :with => '2015-02-09'
    end

    click_button 'Create Prisoner'
    expect(page).to have_content('Prisoner was successfully created.')
    expect(page).to have_content("February 09, 2015")

    click_link 'Edit'
    within('.nested-fields') do
      select('prison#1', :from => 'Prison')
      fill_in 'Date of release', with: '2015-02-10'
    end

    select2_select_multiple(['article#1', 'article#2'], find(:xpath, "//*[contains(@id, 's2id_prisoner_incidents_attributes')][contains(@id, 'article_ids')]//input"))
    select2_select_multiple(['tag#1', 'tag#2'], find(:xpath, "//*[contains(@id, 's2id_prisoner_incidents_attributes')][contains(@id, 'tag_ids')]//input"))

    click_button 'Update Prisoner'

    expect(page).to have_content("Prisoner was successfully updated.")
    expect(page).to have_content("February 09, 2015")
    expect(page).to have_content("prison#1")
    expect(page).to have_content("February 10, 2015")
    expect(page).to have_content("article#1")
    expect(page).to have_content("article#2")
    expect(page).to have_content("tag#1")
    expect(page).to have_content("tag#2")
  end
end