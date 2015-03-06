require 'rspec-rails'

RSpec.describe Prisoner, :type => :model do
  it 'that is saved as the prisoner field of two incidents has exactly those two incidents' do
    prisoner = FactoryGirl.create(:prisoner)
    incident1 = FactoryGirl.create(:incident, prisoner: prisoner)
    incident2 = FactoryGirl.create(:incident, prisoner: prisoner)
    expect(prisoner.incidents).to contain_exactly(incident1, incident2)
  end

  it 'with new incident can only be saved if previous incident has date of release' do
    p1 = FactoryGirl.create(:prisoner)
    i1 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1), date_of_release: nil)
    p1.incidents << i1
    i2 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p1.incidents << i2
    expect { p1.save! }.to raise_error

    i1.update(date_of_release: Date.new(2013, 1, 1))
    expect { p1.save! }.not_to raise_error
  end
end