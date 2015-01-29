require 'rails_helper'

RSpec.describe "criminal_codes/index", :type => :view do
  before(:each) do
    assign(:criminal_codes, [
      CriminalCode.create!(
        :name => "ccode#1"
      ),
      CriminalCode.create!(
        :name => "ccode#2"
      )
    ])
  end

  it "renders a list of criminal_codes" do
    render
    assert_select "tr>td", :text => "ccode#1".to_s, :count => 1
    assert_select "tr>td", :text => "ccode#2".to_s, :count => 1
  end
end
