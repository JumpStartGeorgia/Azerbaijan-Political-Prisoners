require 'rails_helper'

RSpec.describe "incidents/show", :type => :view do
  before(:each) do
    @incident = assign(:incident, FactoryGirl.create(:incident))
  end

  it "renders attributes in <p>" do
    render
  end
end
