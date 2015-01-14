require 'rails_helper'

RSpec.describe "subtypes/index", :type => :view do
  let(:type) { FactoryGirl.create(:type, name: 'MyTypeString') }

  before(:each) do
    assign(:subtypes, [
      FactoryGirl.create(:subtype, name: 'MyString', type: type),
      FactoryGirl.create(:subtype, name: 'MyOtherString', type: type)
    ])
  end

  it "renders a list of subtypes" do
    render
  end
end
