require 'rails_helper'

RSpec.describe "types/show", :type => :view do
  before(:each) do
    @type = assign(:type, FactoryGirl.create(:type, name: 'MyString'))
  end

  it "renders attributes in <p>" do
    render
  end
end
