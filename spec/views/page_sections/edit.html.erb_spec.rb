require 'rails_helper'

RSpec.describe 'page_sections/edit', type: :view do
  before(:each) do
    @page_section = assign(:page_section, PageSection.create!(
                                            name: 'MyString',
                                            label: 'MyString',
                                            content: 'MyText'
    ))
  end

  it 'renders the edit page section form' do
    render

    assert_select 'form[action=?][method=?]', page_section_path(@page_section), 'post' do
      assert_select 'input#page_section_name[name=?]', 'page_section[name]'
      assert_select 'input#page_section_title[name=?]', 'page_section[title]'
      assert_select 'textarea#page_section_content[name=?]', 'page_section[content]'
    end
  end
end
