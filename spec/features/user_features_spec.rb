require 'rails_helper'

RSpec.describe 'User', type: :feature do
  before (:context) do
    @content_manager_role = FactoryGirl.create(:role, name: 'content_manager')
    @content_manager_user = FactoryGirl.create(:user, role: @content_manager_role)
  end

  it "can successfully edit their own password" do
    login_as @content_manager_user, scope: :user
    new_password = 'dsalfkdjsakfjds'

    visit edit_user_registration_path
    within('#edit_user') do
      fill_in 'Password', with: new_password
      fill_in 'Password confirmation', with: new_password
      fill_in 'Current password', with: @content_manager_user.password
    end

    click_button 'Update'
    expect(page).to have_content('Your account has been updated successfully.')
  end
end