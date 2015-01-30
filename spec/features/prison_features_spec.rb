require 'rails_helper'

RSpec.describe "The prison show view", :type => :feature do
  it "renders the names of two prisoners who have incidents that belong to the prison" do
    prison = FactoryGirl.create(:prison)
    prisoner1 = FactoryGirl.create(:prisoner, name: 'pris#1')
    prisoner2 = FactoryGirl.create(:prisoner, name: 'pris#2')
    FactoryGirl.create(:incident, prisoner: prisoner1, prison: prison)
    FactoryGirl.create(:incident, prisoner: prisoner2, prison: prison)

    visit "/prisons/#{prison.id}"
    expect(page).to have_text('pris#1')
    expect(page).to have_text('pris#2')
  end
end