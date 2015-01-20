require 'rspec-rails'

RSpec.describe Prisoner, :type => :model do
  it 'that is saved as the prisoner field of two incidents has exactly those two incidents' do
    prisoner = FactoryGirl.create(:prisoner)
    incident1 = FactoryGirl.create(:incident, prisoner: prisoner)
    incident2 = FactoryGirl.create(:incident, prisoner: prisoner)
    expect(prisoner.incidents).to contain_exactly(incident1, incident2)
  end
end