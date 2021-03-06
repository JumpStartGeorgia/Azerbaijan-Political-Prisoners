require 'rails_helper'

RSpec.describe 'User', type: :feature do
  content_manager_password = 'eqwroipjzvjpo'
  new_content_manager_password = 'dsalfkdjsakfjds'
  site_admin_password = 'kqpiojgipoeczvipn@#!!'

  before (:example) do
    @content_manager_role = FactoryGirl.create(:role, name: 'content_manager')
    @site_admin_role = FactoryGirl.create(:role, name: 'site_admin')
    @super_admin_role = FactoryGirl.create(:role, name: 'super_admin')

    @super_admin_user = FactoryGirl.create(:user, role: @super_admin_role)
    @super_admin_user2 = FactoryGirl.create(:user, role: @super_admin_role)
    @site_admin_user = FactoryGirl.create(:user, role: @site_admin_role, password: site_admin_password)
    @content_manager_user = FactoryGirl.create(:user, role: @content_manager_role, password: content_manager_password)
  end

  describe 'super admin' do
    it "can update another super admin's email and role without updating password" do
      login_as @super_admin_user, scope: :user

      visit edit_user_path(@super_admin_user2)
      within('.inputs') do
        fill_in 'Email', with: 'asdfsdfs@dsafdsf.com'
        select('content_manager', from: 'Role')
      end

      click_button 'Update User'
      expect(page).to have_content('User was successfully updated.')
    end

    it "can update another super admin's email, password and role" do
      login_as @super_admin_user, scope: :user

      visit edit_user_path(@super_admin_user2)
      within('.inputs') do
        fill_in 'Email', with: 'asdfsdfs@dsafdsf.com'
        fill_in 'Password', with: 'asdfsdfdsflkjk;l'
        select('content_manager', from: 'Role')
      end

      click_button 'Update User'
      expect(page).to have_content('User was successfully updated.')
    end
  end

  describe 'site admin' do
    it 'can successfully edit someone else\'s password' do
      # Home page requires app_intro page section
      FactoryGirl.create(:page_section, name: 'app_intro')

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

      find('#user-dropdown').click
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

    it 'can only select site_admin and content_manager in the Roles select on the user create page' do
      login_as @site_admin_user, scope: :user

      visit new_user_path
      expect(page).to have_select 'Role', options: [@site_admin_role.name, @content_manager_role.name]
    end
  end

  describe 'content manager' do
    it 'can successfully edit their own password' do
      # Home page requires app_intro page section
      FactoryGirl.create(:page_section, name: 'app_intro')

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

      find('#user-dropdown').click
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
