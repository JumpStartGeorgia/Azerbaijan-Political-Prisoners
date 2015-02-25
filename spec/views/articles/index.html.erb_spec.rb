require 'rails_helper'

RSpec.describe "articles/index", :type => :view do
  let(:user) { FactoryGirl.create(:user, role: Role.find_by_name("user_manager")) }

  before(:example) do
    sign_in :user, user
  end

  before(:each) do
    assign(:articles, [
      FactoryGirl.create(:article, number: '11.22.33'),
      FactoryGirl.create(:article, number: '22.33.44')
    ])
  end

  it "renders a list of articles" do
    render
  end
end
