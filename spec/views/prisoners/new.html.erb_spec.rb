require 'rails_helper'

RSpec.describe "prisoners/new", :type => :view do
  before(:each) do
    assign(:prisoner, FactoryGirl.build(:prisoner))
  end

  it "renders new prisoner form" do
    render

    assert_select "form[action=?][method=?]", prisoners_path, "post" do
    end
  end
end