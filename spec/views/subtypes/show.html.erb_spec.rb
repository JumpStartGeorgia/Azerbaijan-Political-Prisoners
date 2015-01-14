require 'rails_helper'

RSpec.describe "subtypes/show", :type => :view do
  let(:type) { FactoryGirl.create(:type, name: 'MyTypeString') }

  before(:each) do
    @subtype = assign(:subtype, FactoryGirl.create(:subtype, name: 'MyString', type: type))
  end

  it "renders attributes in <p>" do
    render
  end
end
