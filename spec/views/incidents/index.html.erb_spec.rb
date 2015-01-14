require 'rails_helper'

RSpec.describe "incidents/index", :type => :view do
  before(:each) do
    assign(:incidents, [
      FactoryGirl.create(:incident),
      FactoryGirl.create(:incident)
    ])
  end

  it "renders a list of incidents" do
    render
  end
end
