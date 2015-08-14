require 'rails_helper'

RSpec.describe 'Prisoner and incident', type: :feature do
  it 'can be created using new forms and updated using edit forms', js: true do
    @role = FactoryGirl.create(:role, name: 'content_manager')
    @user = FactoryGirl.create(:user, role: @role)
    login_as(@user, scope: :user)

    prisoner_name = Faker::Name.name

    # Home page requires app_intro page section
    FactoryGirl.create(:page_section, name: 'app_intro')

    FactoryGirl.create(:prison, name: 'prison#1')
    FactoryGirl.create(:article, number: 'article#1')
    FactoryGirl.create(:article, number: 'article#2')
    FactoryGirl.create(:tag, name: 'tag#1')
    FactoryGirl.create(:tag, name: 'tag#2')


    visit prisoners_path

    click_on 'New'

    within('.inputs') do
      fill_in 'Name', with: prisoner_name
      choose('Male')
      fill_in 'Date of birth', with: (Date.today - 50.years).strftime('%Y-%m-%d')
    end

    click_on 'Create Prisoner'

    expect(page).to have_content('Prisoner was successfully created.')
    expect(page).to have_content(prisoner_name)
    expect(page).to have_content('50 years old')

    ####

    click_on 'Add New Incident'

    within('.inputs') do
      fill_in 'Date of arrest', with: '2015-02-09'
    end

    click_on 'Create Incident'

    ####

    click_on 'Edit Incident'

    within('.inputs') do
      select('prison#1', from: 'Prison')
      fill_in 'Date of release', with: '2015-02-10'
    end

    select2_select_multiple(['article#1', 'article#2'], 'incident_articles_input')

    select2_select_multiple(['tag#1', 'tag#2'], 'incident_tags_input')

    click_on 'Update Incident'

    expect(page).to have_content('50 years old')
    expect(page).to have_content('Incident was successfully updated.')
    expect(page).to have_content('February 09, 2015')
    expect(page).to have_content('prison#1')
    expect(page).to have_content('February 10, 2015')
    expect(page).to have_content('article#1')
    expect(page).to have_content('article#2')
    expect(page).to have_content('tag#1')
    expect(page).to have_content('tag#2')
  end
end
