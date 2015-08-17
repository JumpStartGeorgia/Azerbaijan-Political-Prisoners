require 'rails_helper'

RSpec.describe Prisoner, type: :model do
  let(:new_prisoner) { FactoryGirl.build(:prisoner) }

  describe 'cannot be saved' do
    it 'without gender_id' do
      new_prisoner.gender_id = nil
      expect { new_prisoner.save! }.to raise_error
    end

    it 'with gender_id that is not 1, 2 or 3' do
      new_prisoner.gender_id = 4
      expect { new_prisoner.save! }.to raise_error
    end
  end

  describe 'can be saved' do
    it 'with minimum required attributes' do
      expect { new_prisoner.save! }.not_to raise_error
    end
  end

  it 'returns the correct number of imprisoned counts over time for a certain period of time' do
    # Imprisoned the whole time
    new_prisoner = FactoryGirl.create(:prisoner)
    incident1 = FactoryGirl.create(:incident, prisoner: new_prisoner, date_of_arrest: Date.new(2011, 1, 1))
    incident1.run_callbacks(:commit)

    # Imprisoned part of the time
    prisoner3 = FactoryGirl.create(:prisoner)
    incident2 = FactoryGirl.create(:incident, prisoner: prisoner3, date_of_arrest: Date.new(2012, 1, 3), date_of_release: Date.new(2012, 1, 11))
    incident2.run_callbacks(:commit)
    incident3 = FactoryGirl.create(:incident, prisoner: prisoner3, date_of_arrest: Date.new(2014, 1, 1))
    incident3.run_callbacks(:commit)

    prisoner4 = FactoryGirl.create(:prisoner)
    incident4 = FactoryGirl.create(:incident, prisoner: prisoner4, date_of_arrest: Date.new(2009, 8, 5), date_of_release: Date.new(2011, 12, 3))
    incident4.run_callbacks(:commit)
    incident5 = FactoryGirl.create(:incident, prisoner: prisoner4, date_of_arrest: Date.new(2012, 1, 3), date_of_release: Date.new(2012, 1, 8))
    incident5.run_callbacks(:commit)

    prisoner5 = FactoryGirl.create(:prisoner)
    incident6 = FactoryGirl.create(:incident, prisoner: prisoner5, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2007, 12, 8))
    incident6.run_callbacks(:commit)
    incident7 = FactoryGirl.create(:incident, prisoner: prisoner5, date_of_arrest: Date.new(2012, 1, 5), date_of_release: Date.new(2012, 1, 8))
    incident7.run_callbacks(:commit)
    incident8 = FactoryGirl.create(:incident, prisoner: prisoner5, date_of_arrest: Date.new(2014, 12, 5), date_of_release: Date.new(2014, 12, 8))
    incident8.run_callbacks(:commit)

    # Not imprisoned during the period
    prisoner2 = FactoryGirl.create(:prisoner)
    incident9 = FactoryGirl.create(:incident, prisoner: prisoner2, date_of_arrest: Date.new(2014, 1, 1))
    incident9.run_callbacks(:commit)

    prisoner6 = FactoryGirl.create(:prisoner)

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

  it 'returns the correct ids and count of currently imprisoned prisoners' do
    # Currently imprisoned
    new_prisoner.save!
    incident1 = FactoryGirl.create(:incident, prisoner: new_prisoner, date_of_arrest: Date.new(2012, 1, 1))
    incident1.run_callbacks(:commit)

    prisoner2 = FactoryGirl.create(:prisoner)
    incident2 = FactoryGirl.create(:incident, prisoner: prisoner2, date_of_arrest: Date.new(2012, 1, 1))
    incident2.run_callbacks(:commit)

    prisoner3 = FactoryGirl.create(:prisoner)
    incident3 = FactoryGirl.create(:incident, prisoner: prisoner3, date_of_arrest: Date.new(2011, 3, 4), date_of_release: Date.new(2013, 2, 11))
    incident3.run_callbacks(:commit)
    incident4 = FactoryGirl.create(:incident, prisoner: prisoner3, date_of_arrest: Date.new(2014, 1, 1))
    incident4.run_callbacks(:commit)

    # Not currently imprisoned
    prisoner4 = FactoryGirl.create(:prisoner)
    incident5 = FactoryGirl.create(:incident, prisoner: prisoner4, date_of_arrest: Date.new(2009, 8, 5), date_of_release: Date.new(2014, 12, 3))
    incident5.run_callbacks(:commit)
    incident6 = FactoryGirl.create(:incident, prisoner: prisoner4, date_of_arrest: Date.new(2014, 12, 5), date_of_release: Date.new(2014, 12, 8))
    incident6.run_callbacks(:commit)

    prisoner5 = FactoryGirl.create(:prisoner)
    incident7 = FactoryGirl.create(:incident, prisoner: prisoner5, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2007, 12, 8))
    incident7.run_callbacks(:commit)
    incident8 = FactoryGirl.create(:incident, prisoner: prisoner5, date_of_arrest: Date.new(2008, 12, 5), date_of_release: Date.new(2009, 12, 8))
    incident8.run_callbacks(:commit)
    incident9 = FactoryGirl.create(:incident, prisoner: prisoner5, date_of_arrest: Date.new(2010, 12, 5), date_of_release: Date.new(2013, 12, 8))
    incident9.run_callbacks(:commit)

    FactoryGirl.create(:prisoner)

    expect(Prisoner.currently_imprisoned_ids).to eq([new_prisoner.id, prisoner2.id, prisoner3.id])
    expect(Prisoner.currently_imprisoned_count).to eq(3)
  end

  it 'returns the correct number of days in prison' do
    new_prisoner = FactoryGirl.create(:prisoner)
    new_prisoner.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.yesterday)
    prisoner2 = FactoryGirl.create(:prisoner)
    prisoner2.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2005, 3, 5), date_of_release: Date.new(2005, 3, 20))
    prisoner2.incidents << FactoryGirl.create(:incident, date_of_arrest: 5.days.ago)

    expect(new_prisoner.total_days_in_prison).to eq(1)
    expect(prisoner2.total_days_in_prison).to eq(20)
  end

  describe '#destroy' do
    let(:a1) { FactoryGirl.create(:article) }
    let(:i1) { FactoryGirl.create(:incident, articles: [a1]) }
    let(:pris) { FactoryGirl.build(:prisoner, incidents: [i1]) }

    before(:example) do
      pris.save!
    end

    it 'reduces prisoner count by 1' do
      expect { pris.destroy }.to change { Prisoner.count }.by(-1)
    end

    it 'destroys dependent incident' do
      expect { pris.destroy }.to change { Incident.count }.by(-1)
    end

    it 'destroys dependent article' do
      expect { pris.destroy }.to change { Charge.count }.by(-1)
    end
  end

  describe 'age_in_years is correct' do
    it 'when date of birth and current date are same' do
      dob = Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
      new_prisoner.date_of_birth = dob

      expect(new_prisoner.age_in_years).to eq(50)
    end

    it 'when date of birth is tomorrow' do
      dob = Date.new(Date.tomorrow.year - 50,
                     Date.tomorrow.month,
                     Date.tomorrow.day)
      new_prisoner.date_of_birth = dob

      expect(new_prisoner.age_in_years).to eq(49)
    end
  end
end
