require 'rails_helper'

RSpec.describe "page_sections/index", type: :view do
  before(:each) do
    assign(:page_sections, [
      PageSection.create!(
        name: "Name",
        label: "Label",
        content: "MyText"
      ),
      PageSection.create!(
        name: "Name",
        label: "Label",
        content: "MyText"
      )
    ])
  end

  it "renders a list of page_sections" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "Label".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
