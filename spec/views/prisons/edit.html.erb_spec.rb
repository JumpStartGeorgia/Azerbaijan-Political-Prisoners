require 'rails_helper'

RSpec.describe "prisons/edit", :type => :view do
  before(:each) do
    @prison = assign(:prison, Prison.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit prison form" do
    render

    assert_select "form[action=?][method=?]", prison_path(@prison), "post" do

      assert_select "input#prison_name[name=?]", "prison[name]"
    end
  end
end
