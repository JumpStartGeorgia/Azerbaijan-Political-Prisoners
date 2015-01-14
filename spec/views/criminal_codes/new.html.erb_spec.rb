require 'rails_helper'

RSpec.describe "criminal_codes/new", :type => :view do
  before(:each) do
    assign(:criminal_code, CriminalCode.new(
      :name => "MyString"
    ))
  end

  it "renders new criminal_code form" do
    render

    assert_select "form[action=?][method=?]", criminal_codes_path, "post" do

      assert_select "input#criminal_code_name[name=?]", "criminal_code[name]"
    end
  end
end
