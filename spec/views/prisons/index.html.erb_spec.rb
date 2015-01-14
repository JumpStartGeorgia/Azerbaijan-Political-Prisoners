require 'rails_helper'

RSpec.describe "prisons/index", :type => :view do
  before(:each) do
    assign(:prisons, [
      Prison.create!(
        :name => "Name"
      ),
      Prison.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of prisons" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
