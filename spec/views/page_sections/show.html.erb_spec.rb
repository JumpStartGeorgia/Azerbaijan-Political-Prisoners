require 'rails_helper'

RSpec.describe "page_sections/show", type: :view do
  before(:each) do
    @page_section = assign(:page_section, PageSection.create!(
      name: "Name",
      label: "Label",
      content: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Label/)
    expect(rendered).to match(/MyText/)
  end
end
