require 'rails_helper'

RSpec.describe "prisons/new", :type => :view do
  before(:each) do
    assign(:prison, Prison.new(
      :name => "MyString"
    ))
  end

  it "renders new prison form" do
    render

    assert_select "form[action=?][method=?]", prisons_path, "post" do

      assert_select "input#prison_name[name=?]", "prison[name]"
    end
  end
end
