require 'rails_helper'

RSpec.describe "types/index", :type => :view do
  before(:each) do
    assign(:types, [
      FactoryGirl.create(:type, name: 'MyString'),
      FactoryGirl.create(:type, name: 'MyOtherString')
    ])
  end

  it "renders a list of types" do
    render
  end
end
