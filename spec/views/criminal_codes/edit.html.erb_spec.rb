require 'rails_helper'

RSpec.describe "criminal_codes/edit", :type => :view do
  before(:each) do
    @criminal_code = assign(:criminal_code, CriminalCode.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit criminal_code form" do
    render

    assert_select "form[action=?][method=?]", criminal_code_path(@criminal_code), "post" do

      assert_select "input#criminal_code_name[name=?]", "criminal_code[name]"
    end
  end
end
