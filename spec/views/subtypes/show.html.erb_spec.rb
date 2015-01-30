require 'rails_helper'

RSpec.describe 'subtypes/show', :type => :view do
  it "renders two prisoners with incidents of current subtype" do
    @subtype = assign(:subtype, FactoryGirl.create(:subtype))
    prisoner1 = FactoryGirl.create(:prisoner, name: 'prisoner#1')
    prisoner2 = FactoryGirl.create(:prisoner, name: 'prisoner#2')
    FactoryGirl.create(:incident, subtype: @subtype, prisoner: prisoner1)
    FactoryGirl.create(:incident, subtype: @subtype, prisoner: prisoner2)
    @subtype_prisoners = assign(:subtype_prisoners, Prisoner.by_subtype(@subtype))

    render

    expect(rendered).to include('prisoner#1')
    expect(rendered).to include('prisoner#2')
  end
end