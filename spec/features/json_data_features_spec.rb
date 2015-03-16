require 'rails_helper'

RSpec.describe 'JSON data', type: :feature do
  before(:example) do
    @role = FactoryGirl.create(:role, name: 'user_manager')
    @user = FactoryGirl.create(:user, role: @role)
  end

  it "for charts update when a new prisoner is created", js: true do
    login_as(@user, scope: :user)

    prison1 = FactoryGirl.create(:prison, name: 'prison#1')
    prison2 = FactoryGirl.create(:prison, name: 'prison#2')

    article1 = FactoryGirl.create(:article, number: 'article#1')
    article2 = FactoryGirl.create(:article, number: 'article#2')

    p1 = FactoryGirl.create(:prisoner)
    i1 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1), prison: prison1)
    i1.articles << article1
    p1.incidents << i1
    p1.run_callbacks(:commit)

    p2 = FactoryGirl.create(:prisoner)
    i2 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1), prison: prison2)
    i2.articles << article2
    p2.incidents << i2
    p2.run_callbacks(:commit)

    p3 = FactoryGirl.create(:prisoner)
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1), prison: prison1)
    p3.run_callbacks(:commit)

    timeline_json_path = "/chart_data/imprisoned_count_timeline"
    prison_prisoner_counts_json_path = "/chart_data/prison_prisoner_counts"
    article_incident_counts_json_path = "/chart_data/article_incident_counts"

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
      select('prison#2', from: 'Prison')

    end

    select2_select_multiple(['article#1'], 'prisoner_incidents_attributes_0_article_ids')

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

def select2_select_multiple(select_these, id)
  # This methods requires @javascript in the Scenario
  [select_these].flatten.each do | value |
    full_id = "#s2id_#{id}"
    puts 'FULL ID: ' + full_id


    clickable_input = find(:xpath, "//*[contains(@id, 's2id_prisoner_incidents_attributes')][contains(@id, 'article_ids')]//input")
    clickable_input.click
    found = false
    within("#select2-drop") do
      all('li.select2-result').each do | result |
        unless found
          if result.text == value
            result.click
            found = true
          end
        end
      end
    end
  end
end