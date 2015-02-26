require 'rails_helper'

RSpec.describe 'User', type: :feature do
  before (:context) do
    @user_manager_role = FactoryGirl.create(:role, name: 'user_manager')
    @user_manager_user = FactoryGirl.create(:user, role: @user_manager_role)
  end

  it "can successfully edit their own password" do
    login_as @user_manager_user, scope: :user
    new_password = 'dsalfkdjsakfjds'

    visit edit_user_registration_path
    within('#edit_user') do
      fill_in 'Password', with: new_password
      fill_in 'Password confirmation', with: new_password
      fill_in 'Current password', with: @user_manager_user.password
    end

    click_button 'Update'
    expect(page).to have_content('Your account has been updated successfully.')
  end
end