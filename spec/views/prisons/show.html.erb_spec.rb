require 'rails_helper'

RSpec.describe "prisons/show", :type => :view do
  it "renders two prisoners with incidents that belong_to the prison" do
    @prison = assign(:prison, FactoryGirl.create(:prison))
    prisoner1 = FactoryGirl.create(:prisoner, name: 'pris#1')
    prisoner2 = FactoryGirl.create(:prisoner, name: 'pris#2')
    FactoryGirl.create(:incident, prison: @prison, prisoner: prisoner1)
    FactoryGirl.create(:incident, prison: @prison, prisoner: prisoner2)
    @prisoners_in_prison = assign(:prisoners_in_prison, Prisoner.by_prison(@prison))

    render
    expect(rendered).to include('pris#1')
    expect(rendered).to include('pris#2')
  end
end
