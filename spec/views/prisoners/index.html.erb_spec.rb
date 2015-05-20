require 'rails_helper'

RSpec.describe "prisoners/index", :type => :view do
  let(:user) { FactoryGirl.create(:user, role: Role.find_by_name("user_manager")) }

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
    render prisoners_path
  end
end
