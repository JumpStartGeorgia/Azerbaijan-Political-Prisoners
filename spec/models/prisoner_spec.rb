require 'rspec-rails'

RSpec.describe Prisoner, :type => :model do
  let(:p1) { FactoryGirl.build(:prisoner) }

  it 'with new incident can only be saved if previous incident has date of release' do
    i1 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1), date_of_release: nil)
    p1.incidents << i1
    i2 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p1.incidents << i2
    expect { p1.save! }.to raise_error

    i1.update(date_of_release: Date.new(2013, 1, 1))
    expect { p1.save! }.not_to raise_error
  end

  it "cannot be saved if dates of arrest and dates of release are not in chronological order" do
    i1 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1), date_of_release: Date.new(2011, 1, 1))
    p1.incidents << i1
    i2 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2010, 1, 1))
    p1.incidents << i2
    expect { p1.save! }.to raise_error

    i1.update(date_of_release: Date.new(2013, 1, 1))
    expect { p1.save! }.to raise_error

    i2.update(date_of_arrest: Date.new(2014, 1, 1))
    expect { p1.save! }.not_to raise_error
  end

  it "cannot be saved if a date of arrest or date of release is after today" do
    i1 = FactoryGirl.create(:incident, date_of_arrest: Date.tomorrow, date_of_release: 10.days.from_now)
    p1.incidents << i1
    expect { p1.save! }.to raise_error

    i1.update(date_of_arrest: 10.days.ago)
    expect { p1.save! }.to raise_error

    i1.update(date_of_release: Date.yesterday)
    expect { p1.save! }.not_to raise_error
  end
end