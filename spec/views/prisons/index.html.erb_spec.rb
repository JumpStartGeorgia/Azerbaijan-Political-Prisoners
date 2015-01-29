require 'rails_helper'

RSpec.describe "prisons/index", :type => :view do
  before(:each) do
    assign(:prisons, [
      Prison.create!(
        :name => "Name1"
      ),
      Prison.create!(
        :name => "Name2"
      )
    ])
  end

  it "renders a list of prisons" do
    render
    assert_select "tr>td", :text => "Name1".to_s, :count => 1
    assert_select "tr>td", :text => "Name2".to_s, :count => 1
  end
end
