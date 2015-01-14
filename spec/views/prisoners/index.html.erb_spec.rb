require 'rails_helper'

RSpec.describe "prisoners/index", :type => :view do
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
