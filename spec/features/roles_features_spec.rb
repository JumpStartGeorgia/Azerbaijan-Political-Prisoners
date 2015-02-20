require 'rails_helper'

RSpec.describe "Role", :type => :feature do
  before(:context) do
    @super_admin_role = FactoryGirl.create(:role, name: 'super_admin')
    @site_admin_role = FactoryGirl.create(:role, name: 'site_admin')
    @user_manager_role = FactoryGirl.create(:role, name: 'user_manager')

    @super_admin_user = FactoryGirl.create(:user, role: @super_admin_role)
    @super_admin_user2 = FactoryGirl.create(:user, role: @super_admin_role)

    @site_admin_user = FactoryGirl.create(:user, role: @site_admin_role)

    @user_manager_user = FactoryGirl.create(:user, role: @user_manager_role)
  end

  describe "super admin" do
    it "can update another super admin's email and role without updating password" do
      login_as @super_admin_user, scope: :user

      visit edit_user_path(@super_admin_user2)
      within('.inputs') do
        fill_in 'Email', :with => 'asdfsdfs@dsafdsf.com'
        select('user_manager', :from => 'Role')
      end

      click_button 'Update User'
      expect(page).to have_content('User was successfully updated.')
    end

    it "can update another super admin's email, password and role" do
      login_as @super_admin_user, scope: :user

      visit edit_user_path(@super_admin_user2)
      within('.inputs') do
        fill_in 'Email', :with => 'asdfsdfs@dsafdsf.com'
        fill_in 'Password', with: 'asdfsdfdsflkjk;l'
        select('user_manager', :from => 'Role')
      end

      click_button 'Update User'
      expect(page).to have_content('User was successfully updated.')
    end
  end

  describe "site admin" do
    it "can only select site_admin and user_manager in the Roles select on the user create page" do
      login_as @site_admin_user, scope: :user

      visit new_user_path
      expect(page).to have_select('Role', options: ['site_admin', 'user_manager'])
    end
  end

  describe "user manager" do
    it "can only select user_manager in the Roles select on the user create page" do
      login_as @user_manager_user, scope: :user

      visit new_user_path
      expect(page).to have_select('Role', options: ['user_manager'])
    end
  end
end