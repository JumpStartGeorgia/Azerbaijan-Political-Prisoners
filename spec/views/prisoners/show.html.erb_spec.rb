require 'rails_helper'

RSpec.describe "prisoners/show", :type => :view do
  before(:each) do
    @prisoner = assign(:prisoner, FactoryGirl.create(:prisoner))
  end

  it "renders attributes in <p>" do
    render
  end
end
