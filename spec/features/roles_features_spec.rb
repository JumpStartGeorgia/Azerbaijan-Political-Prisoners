require 'rails_helper'

RSpec.describe "Role", :type => :feature do
  before(:context) do
    @super_admin_role = FactoryGirl.create(:role, name: 'super_admin')
    @site_admin_role = FactoryGirl.create(:role, name: 'site_admin')
    @user_manager_role = FactoryGirl.create(:role, name: 'user_manager')
  end

  describe "super admin" do
    before(:context) do
      @user = FactoryGirl.create(:user, role: @super_admin_role)
      @user2 = FactoryGirl.create(:user, role: @super_admin_role)
    end

    it "can update another super admin's email and role without updating password" do
      login_as @user, scope: :user

      visit edit_user_path(@user2)
      within('.inputs') do
        fill_in 'Email', :with => 'asdfsdfs@dsafdsf.com'
        select('user_manager', :from => 'Role')
      end

      click_button 'Update User'
      expect(page).to have_content('User was successfully updated.')
    end

    it "can update another super admin's email, password and role" do
      login_as @user, scope: :user

      visit edit_user_path(@user2)
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
    it "cannot update another user's role to super_admin" do
      skip()
    end
  end

  describe "user manager" do
    it "cannot update another user's role to site_admin" do
      skip()
    end

    it "cannot update it's own role to site_admin" do
      skip()
    end
  end
end