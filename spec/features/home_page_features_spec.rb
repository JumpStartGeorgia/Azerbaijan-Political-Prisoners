require 'rails_helper'

RSpec.describe 'Home page', type: :feature do
  before(:context) do
    # Two prisoners, each with one incident and no date of release
    p1 = FactoryGirl.create(:prisoner_with_incidents)
    p1.run_callbacks(:commit)
    p2 = FactoryGirl.create(:prisoner_with_incidents)
    p2.run_callbacks(:commit)

    # Prisoner with two incidents, first has date of release and second does not
    p3 = FactoryGirl.create(:prisoner)
    p3.incidents << FactoryGirl.create(:incident, date_of_release: Date.new(2013, 2, 11))
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p3.run_callbacks(:commit)

    # Prisoner with two incidents, both of which have date of release
    p4 = FactoryGirl.create(:prisoner)
    p4.incidents << FactoryGirl.create(:incident, date_of_release: Date.new(2014, 12, 3))
    p4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 12, 5), date_of_release: Date.new(2014, 12, 8))
    p4.run_callbacks(:commit)

    # Prisoner with three incidents, all three have date of release
    p5 = FactoryGirl.create(:prisoner)
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2007, 12, 8))
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2008, 12, 5), date_of_release: Date.new(2009, 12, 8))
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2010, 12, 5), date_of_release: Date.new(2013, 12, 8))
    p5.run_callbacks(:commit)

    # Prisoner with no incidents
    p6 = FactoryGirl.create(:prisoner)
    p6.run_callbacks(:commit)
  end

  it "displays the correct number of currently imprisoned prisoners" do
    visit root_path
    expect(page).to have_text('Number of people currently imprisoned in Azerbaijan for political purposes: 3')
  end
end