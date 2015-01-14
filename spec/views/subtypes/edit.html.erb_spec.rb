require 'rails_helper'

RSpec.describe "subtypes/edit", :type => :view do
  let(:type) { FactoryGirl.create(:type, name: 'MyTypeString') }

  before(:each) do
    @subtype = assign(:subtype, FactoryGirl.create(:subtype, name: 'MyString', type: type))
  end

  it "renders the edit subtype form" do
    render

    assert_select "form[action=?][method=?]", subtype_path(@subtype), "post" do
    end
  end
end
