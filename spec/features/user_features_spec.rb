require 'rails_helper'

RSpec.describe 'User', type: :feature, js: true do
  content_manager_password = 'eqwroipjzvjpo'
  new_content_manager_password = 'dsalfkdjsakfjds'

  before (:example) do
    FactoryGirl.create(:prisoner, incidents: [FactoryGirl.create(:incident)])

    @content_manager_role = FactoryGirl.create(:role, name: 'content_manager')
    @content_manager_user = FactoryGirl.create(:user, role: @content_manager_role, password: content_manager_password)
  end

  describe 'content manager' do
    it 'can successfully edit their own password' do
      visit new_user_session_path
      within('#new_user') do
        fill_in 'Email', with: @content_manager_user.email
        fill_in 'Password', with: content_manager_password
      end

      click_on 'Log in'
      expect(page).to have_content('Signed in successfully.')

      visit edit_user_registration_path
      within('#edit_user') do
        fill_in 'Password', with: new_content_manager_password
        fill_in 'Password confirmation', with: new_content_manager_password
        fill_in 'Current password', with: @content_manager_user.password
      end

      click_button 'Update'
      expect(page).to have_content('Your account has been updated successfully.')

      click_on @content_manager_user.email
      click_on 'Logout'
      expect(page).to have_content('Signed out successfully.')

      visit new_user_session_path
      within('#new_user') do
        fill_in 'Email', with: @content_manager_user.email
        fill_in 'Password', with: new_content_manager_password
      end

      click_on 'Log in'
      expect(page).to have_content('Signed in successfully.')
    end
  end

  describe 'site admin' do
    it 'can successfully edit someone else\'s password' do
      FactoryGirl.create(:prisoner, incidents: [FactoryGirl.create(:incident)])

      site_admin_password = 'kqpiojgipoeczvipn@#!!'
      @site_admin_role = FactoryGirl.create(:role, name: 'site_admin')
      @site_admin_user = FactoryGirl.create(:user, role: @site_admin_role, password: site_admin_password)

      visit new_user_session_path
      within('#new_user') do
        fill_in 'Email', with: @site_admin_user.email
        fill_in 'Password', with: site_admin_password
      end

      click_on 'Log in'
      expect(page).to have_content('Signed in successfully.')

      visit edit_user_path(@content_manager_user)
      within('.inputs') do
        fill_in 'Password', with: new_content_manager_password
      end

      click_on 'Update User'
      expect(page).to have_content('User was successfully updated.')

      click_on @site_admin_user.email
      click_on 'Logout'
      expect(page).to have_content('Signed out successfully.')

      visit new_user_session_path
      within('#new_user') do
        fill_in 'Email', with: @content_manager_user.email
        fill_in 'Password', with: new_content_manager_password
      end

      click_on 'Log in'
      expect(page).to have_content('Signed in successfully.')
    end
  end
end
