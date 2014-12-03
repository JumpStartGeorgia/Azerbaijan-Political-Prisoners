require 'rails_helper'

RSpec.describe "prisons/show", :type => :view do
  before(:each) do
    @prison = assign(:prison, Prison.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
