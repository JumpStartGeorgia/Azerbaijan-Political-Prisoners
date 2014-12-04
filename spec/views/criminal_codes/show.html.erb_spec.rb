require 'rails_helper'

RSpec.describe "criminal_codes/show", :type => :view do
  before(:each) do
    @criminal_code = assign(:criminal_code, CriminalCode.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
