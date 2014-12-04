require 'rails_helper'

RSpec.describe "criminal_codes/index", :type => :view do
  before(:each) do
    assign(:criminal_codes, [
      CriminalCode.create!(
        :name => "Name"
      ),
      CriminalCode.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of criminal_codes" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
