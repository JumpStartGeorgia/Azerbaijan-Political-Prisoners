require 'rails_helper'

RSpec.describe "prisoners/index", :type => :view do
  let(:user_manager_role) { FactoryGirl.create(:role, name: 'user_manager') }
  let(:user) { FactoryGirl.create(:user, role: user_manager_role) }

  before(:example) do
    sign_in :user, user
  end

  before(:each) do
    assign(:prisoners, [
      FactoryGirl.create(:prisoner),
      FactoryGirl.create(:prisoner)
    ])
  end

  it "renders a list of prisoners" do
    render
  end
end
