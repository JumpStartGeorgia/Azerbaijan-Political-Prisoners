require 'rails_helper'

RSpec.describe 'Home page', type: :feature do
  before(:context) do
    # Two prisoners, each with one incident and no date of release
    FactoryGirl.create(:prisoner_with_incidents)
    FactoryGirl.create(:prisoner_with_incidents)

    # Prisoner with two incidents, first has date of release and second does not
    prisoner3 = FactoryGirl.create(:prisoner)
    prisoner3.incidents << FactoryGirl.create(:incident, date_of_release: Date.new(2013, 2, 11))
    prisoner3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))


    # Prisoner with two incidents, both of which have date of release
    prisoner4 = FactoryGirl.create(:prisoner)
    prisoner4.incidents << FactoryGirl.create(:incident, date_of_release: Date.new(2014, 12, 3))
    prisoner4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 12, 5), date_of_release: Date.new(2014, 12, 8))

    # Prisoner with three incidents, all three have date of release
    prisoner5 = FactoryGirl.create(:prisoner)
    prisoner5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2007, 12, 8))
    prisoner5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2008, 12, 5), date_of_release: Date.new(2009, 12, 8))
    prisoner5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2010, 12, 5), date_of_release: Date.new(2013, 12, 8))
  end

  it "displays the correct number of currently imprisoned prisoners" do
    visit root_path
    expect(page).to have_text('Number of people currently imprisoned in Azerbaijan for political purposes: 3')
  end
end