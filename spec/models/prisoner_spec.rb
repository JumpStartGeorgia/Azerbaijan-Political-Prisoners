require 'rspec-rails'

RSpec.describe Prisoner, :type => :model do
  let(:p1) { FactoryGirl.build(:prisoner) }

  describe "cannot be saved" do
    it 'if date of release is nil for any but the last incident' do
      i1 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1), date_of_release: nil)
      p1.incidents << i1
      i2 = FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
      p1.incidents << i2
      expect { p1.save! }.to raise_error

      i1.update(date_of_release: Date.new(2013, 1, 1))
      expect { p1.save! }.not_to raise_error
    end

    it "if dates of arrest and dates of release are not in chronological order" do
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

    it "if a date of arrest or date of release is after today" do
      i1 = FactoryGirl.create(:incident, date_of_arrest: Date.tomorrow, date_of_release: 10.days.from_now)
      p1.incidents << i1
      expect { p1.save! }.to raise_error

      i1.update(date_of_arrest: 10.days.ago)
      expect { p1.save! }.to raise_error

      i1.update(date_of_release: Date.yesterday)
      expect { p1.save! }.not_to raise_error
    end
  end

  it "returns the correct number of imprisoned for a certain date" do
    # Two prisoners, each with one incident and no date of release
    p1 = FactoryGirl.create(:prisoner)
    p1.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1))
    p1.run_callbacks(:commit)

    p2 = FactoryGirl.create(:prisoner)
    p2.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p2.run_callbacks(:commit)

    # Prisoner with two incidents, first has date of release and second does not
    p3 = FactoryGirl.create(:prisoner)
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2011, 3, 4), date_of_release: Date.new(2012, 2, 11))
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p3.run_callbacks(:commit)

    # Prisoner with two incidents, both of which have date of release
    p4 = FactoryGirl.create(:prisoner)
    p4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2009, 8, 5), date_of_release: Date.new(2012, 12, 3))
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

    expect(Prisoner.imprisoned_count(Date.new(2013, 1, 1))).to eq(2)

    imprisoned = Prisoner.imprisoned_ids(Date.new(2013, 1, 1))
    expect(imprisoned).to eq([p1.id, p5.id])
  end

  it "returns the correct number of imprisoned counts over time for a certain period of time" do
    # Imprisoned the whole time
    p1 = FactoryGirl.create(:prisoner)
    p1.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2011, 1, 1))
    p1.run_callbacks(:commit)

    # Imprisoned part of the time
    p3 = FactoryGirl.create(:prisoner)
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 3), date_of_release: Date.new(2012, 1, 11))
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p3.run_callbacks(:commit)

    p4 = FactoryGirl.create(:prisoner)
    p4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2009, 8, 5), date_of_release: Date.new(2011, 12, 3))
    p4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 3), date_of_release: Date.new(2012, 1, 8))
    p4.run_callbacks(:commit)

    p5 = FactoryGirl.create(:prisoner)
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2007, 12, 8))
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 5), date_of_release: Date.new(2012, 1, 8))
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 12, 5), date_of_release: Date.new(2014, 12, 8))
    p5.run_callbacks(:commit)

    # Not imprisoned during the period
    p2 = FactoryGirl.create(:prisoner)
    p2.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p2.run_callbacks(:commit)

    p6 = FactoryGirl.create(:prisoner)
    p6.run_callbacks(:commit)

    expected_dates_and_counts = [
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 1)), 1],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 2)), 1],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 3)), 3],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 4)), 3],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 5)), 4],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 6)), 4],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 7)), 4],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 8)), 2],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 9)), 2],
        [Prisoner.convert_date_to_utc(Date.new(2012, 1, 10)), 2]
    ]

    expect(Prisoner.imprisoned_counts_from_date_to_date(Date.new(2012, 1, 1), Date.new(2012, 1, 10))).to eq(expected_dates_and_counts)
  end

  it "returns the correct ids and count of currently imprisoned prisoners" do
    # Currently imprisoned
    p1 = FactoryGirl.create(:prisoner)
    p1.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1))
    p1.run_callbacks(:commit)

    p2 = FactoryGirl.create(:prisoner)
    p2.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2012, 1, 1))
    p2.run_callbacks(:commit)

    p3 = FactoryGirl.create(:prisoner)
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2011, 3, 4), date_of_release: Date.new(2013, 2, 11))
    p3.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    p3.run_callbacks(:commit)

    # Not currently imprisoned
    p4 = FactoryGirl.create(:prisoner)
    p4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2009, 8, 5), date_of_release: Date.new(2014, 12, 3))
    p4.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 12, 5), date_of_release: Date.new(2014, 12, 8))
    p4.run_callbacks(:commit)

    p5 = FactoryGirl.create(:prisoner)
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2007, 12, 8))
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2008, 12, 5), date_of_release: Date.new(2009, 12, 8))
    p5.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2010, 12, 5), date_of_release: Date.new(2013, 12, 8))
    p5.run_callbacks(:commit)

    p6 = FactoryGirl.create(:prisoner)
    p6.run_callbacks(:commit)

    expect(Prisoner.currently_imprisoned_ids).to eq([p1.id, p2.id, p3.id])
    expect(Prisoner.currently_imprisoned_count).to eq(3)
  end
end