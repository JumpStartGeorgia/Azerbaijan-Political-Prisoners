require 'rails_helper'

RSpec.describe 'JSON data', type: :feature do
  before(:example) do
    @role = FactoryGirl.create(:role, name: 'content_manager')
    @user = FactoryGirl.create(:user, role: @role)
  end

  it 'for charts update when a new prisoner is created and when a prisoner is updated', js: true do
    login_as(@user, scope: :user)

    FactoryGirl.create(:prison, name: 'prison#1')
    FactoryGirl.create(:prison, name: 'prison#2')

    FactoryGirl.create(:article, number: 'article#1')
    FactoryGirl.create(:article, number: 'article#2')

    timeline_json_path = '/prisoners/imprisoned_count_timeline'
    prison_prisoner_counts_json_path = '/prisons/prison_prisoner_counts'
    article_incident_counts_json_path = '/articles/article_incident_counts'

    visit timeline_json_path
    timeline_json1 = page.body

    visit prison_prisoner_counts_json_path
    prison_prisoner_counts_json1 = page.body

    visit article_incident_counts_json_path
    article_incident_counts_json1 = page.body

    visit new_prisoner_path

    within('.inputs') do
      fill_in 'Name', with: 'Bob Jones'
    end

    click_link 'Add New Incident'

    within('.nested-fields') do
      fill_in 'Date of arrest', with: '2015-01-01'
      select('prison#1', from: 'Prison')
    end

    select2_select_multiple(['article#1'], find(:xpath, "//*[contains(@id, 's2id_prisoner_incidents_attributes')][contains(@id, 'article_ids')]//input"))

    click_button 'Create Prisoner'
    expect(page).to have_content('Prisoner was successfully created.')

    visit timeline_json_path
    timeline_json2 = page.body
    expect(timeline_json1).not_to eq(timeline_json2)

    visit prison_prisoner_counts_json_path
    prison_prisoner_counts_json2 = page.body
    expect(prison_prisoner_counts_json1).not_to eq(prison_prisoner_counts_json2)

    visit article_incident_counts_json_path
    article_incident_counts_json2 = page.body
    expect(article_incident_counts_json1).not_to eq(article_incident_counts_json2)

    visit edit_prisoner_path(Prisoner.find_by_name('Bob Jones').id)

    within('.nested-fields') do
      fill_in 'Date of release', with: '2015-02-10'
      select('prison#2', from: 'Prison')
    end

    select2_select_multiple(['article#2'], find(:xpath, "//*[contains(@id, 's2id_prisoner_incidents_attributes')][contains(@id, 'article_ids')]//input"))

    click_button 'Update Prisoner'
    expect(page).to have_content('Prisoner was successfully updated.')

    visit root_path

    visit timeline_json_path
    timeline_json3 = page.body
    expect(timeline_json2).not_to eq(timeline_json3)

    visit prison_prisoner_counts_json_path
    prison_prisoner_counts_json3 = page.body
    expect(prison_prisoner_counts_json2).not_to eq(prison_prisoner_counts_json3)

    visit article_incident_counts_json_path
    article_incident_counts_json3 = page.body
    expect(article_incident_counts_json2).not_to eq(article_incident_counts_json3)
  end
end
