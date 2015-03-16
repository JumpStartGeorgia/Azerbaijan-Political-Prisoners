require 'rails_helper'

RSpec.describe 'JSON data', type: :feature do
  before(:example) do
    @role = FactoryGirl.create(:role, name: 'user_manager')
    @user = FactoryGirl.create(:user, role: @role)
  end

  it "for charts update when a new prisoner is created", js: true do
    Capybara::Session.new(Capybara.default_driver)

    login_as(@user, scope: :user)

    p1 = FactoryGirl.create(:prisoner)
    p1.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1))
    p1.run_callbacks(:commit)

    p2 = FactoryGirl.create(:prisoner)
    p2.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1))
    p2.run_callbacks(:commit)

    p3 = FactoryGirl.create(:prisoner)
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p3.run_callbacks(:commit)

    timeline_json_path = "/chart_data/imprisoned_count_timeline"
    prison_prisoner_counts_json_path = "/chart_data/prison_prisoner_counts"
    article_incident_counts_json_path = "chart_data/article_incident_counts"

    # Visit root and save json data in variables
    visit root_path

    visit timeline_json_path
    old_timeline_json = page.body

    visit prison_prisoner_counts_json_path
    old_prison_prisoner_counts_json = page.body

    visit article_incident_counts_json_path
    old_article_incident_counts_json = page.body

    ##Add date of release to p3
    #visit edit_prisoner_path(p3)
    #within('.nested-fields') do
    #  fill_in 'Date of arrest', with: '2015-01-01'
    #  #fill_in 'Date of release', with: '2015-02-10'
    #end
    #
    #click_button 'Update Prisoner'
    #expect(page).to have_content("Prisoner was successfully updated.")

    visit new_prisoner_path

    within('.inputs') do
      fill_in 'Name', :with => 'Bob Jones'
    end

    click_link 'Add New Incident'

    within('.nested-fields') do
      fill_in 'Date of arrest', with: '2015-01-01'
    end

    click_button 'Create Prisoner'
    expect(page).to have_content('Prisoner was successfully created.')

    # Visit root and compare old json data to new json data
    visit root_path

    visit timeline_json_path
    new_timeline_json = page.body
    expect(old_timeline_json).not_to eq(new_timeline_json)

    visit prison_prisoner_counts_json_path
    new_prison_prisoner_counts_json = page.body
    expect(old_prison_prisoner_counts_json).not_to eq(new_prison_prisoner_counts_json)

    visit article_incident_counts_json_path
    new_article_incident_counts_json = page.body
    expect(old_article_incident_counts_json).not_to eq(new_article_incident_counts_json)
  end
end