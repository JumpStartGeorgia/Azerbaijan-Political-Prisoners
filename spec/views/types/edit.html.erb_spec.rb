require 'rails_helper'

RSpec.describe "types/edit", :type => :view do
  before(:each) do
    @type = assign(:type, FactoryGirl.create(:type, name: 'MyString'))
  end

  it "renders the edit type form" do
    render

    assert_select "form[action=?][method=?]", type_path(@type), "post" do
    end
  end
end
