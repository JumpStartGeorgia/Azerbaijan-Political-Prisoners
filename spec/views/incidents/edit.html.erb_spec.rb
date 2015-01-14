require 'rails_helper'

RSpec.describe "incidents/edit", :type => :view do
  before(:each) do
    @incident = assign(:incident, FactoryGirl.create(:incident))
  end

  it "renders the edit incident form" do
    render

    assert_select "form[action=?][method=?]", incident_path(@incident), "post" do
    end
  end
end
