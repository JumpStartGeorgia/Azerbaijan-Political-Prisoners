require 'rails_helper'

RSpec.describe Incident, :type => :model do
  it 'without Prisoner is invalid' do
    incident = FactoryGirl.build(:incident, prisoner: nil)
    expect { incident.save! }.to raise_error
  end

  it 'without Date of Arrest is invalid' do
    incident = FactoryGirl.build(:incident, date_of_arrest: nil)
    expect { incident.save! }.to raise_error
  end
end