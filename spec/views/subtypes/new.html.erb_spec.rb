require 'rails_helper'

RSpec.describe "subtypes/new", :type => :view do
  let(:type) { FactoryGirl.create(:type, name: 'MyTypeString') }

  before(:each) do
    assign(:subtype, FactoryGirl.build(:subtype, name: 'MyString', type: type))
  end

  it "renders new subtype form" do
    render

    assert_select "form[action=?][method=?]", subtypes_path, "post" do
    end
  end
end
