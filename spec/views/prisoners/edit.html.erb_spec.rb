require 'rails_helper'

RSpec.describe "prisoners/edit", :type => :view do
  before(:each) do
    @prisoner = assign(:prisoner, FactoryGirl.create(:prisoner))
  end

  it "renders the edit prisoner form" do
    render

    assert_select "form[action=?][method=?]", prisoner_path(@prisoner), "post" do
    end
  end
end
