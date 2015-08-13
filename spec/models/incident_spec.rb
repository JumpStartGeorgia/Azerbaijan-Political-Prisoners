require 'rails_helper'

RSpec.describe Incident, type: :model do
  let(:date_of_arrest) { Date.new(2000, 5, 5) }
  let(:prisoner) { FactoryGirl.create(:prisoner) }

  let(:new_incident) do
    FactoryGirl.build(
      :incident,
      prisoner: prisoner,
      date_of_arrest: date_of_arrest,
    )
  end

  let(:previous_incident) do
    FactoryGirl.create(
      :incident,
      prisoner: prisoner,
      date_of_arrest: date_of_arrest - 365,
      date_of_release: date_of_arrest - 364
    )
  end

  let(:earliest_incident) do
    FactoryGirl.create(
      :incident,
      prisoner: prisoner,
      date_of_arrest: date_of_arrest - 730,
      date_of_release: date_of_arrest - 729
    )
  end

  let(:subsequent_incident) do
    FactoryGirl.create(
      :incident,
      prisoner: prisoner,
      date_of_arrest: date_of_arrest + 365,
      date_of_release: date_of_arrest + 366
    )
  end

  let(:latest_incident) do
    FactoryGirl.create(
      :incident,
      prisoner: prisoner,
      date_of_arrest: date_of_arrest + 730,
      date_of_release: date_of_arrest + 731
    )
  end

  it 'is valid with valid attributes' do
    expect(new_incident).to be_valid
  end

  describe 'prisoner' do
    it 'is required' do
      new_incident.prisoner = nil
      expect(new_incident).to have(1).error_on(:prisoner)
    end
  end

  describe 'date of arrest' do
    it 'is required' do
      new_incident.date_of_arrest = nil
      expect(new_incident).to have(1).error_on(:date_of_arrest)
    end

    it 'yesterday does not cause error' do
      new_incident.date_of_arrest = Date.yesterday
      expect(new_incident).to have(0).error_on(:date_of_arrest)
    end

    it 'today does not cause error' do
      new_incident.date_of_arrest = Date.today
      expect(new_incident).to have(0).error_on(:date_of_arrest)
    end

    it 'tomorrow causes error' do
      new_incident.date_of_arrest = Date.tomorrow
      expect(new_incident).to have(1).error_on(:date_of_arrest)
    end
  end

  describe 'date of release' do
    it 'yesterday does not cause error' do
      new_incident.date_of_release = Date.yesterday
      expect(new_incident).to have(0).error_on(:date_of_release)
    end

    it 'today does not cause error' do
      new_incident.date_of_release = Date.today
      expect(new_incident).to have(0).error_on(:date_of_release)
    end

    it 'tomorrow causes error' do
      new_incident.date_of_release = Date.tomorrow
      expect(new_incident).to have(1).error_on(:date_of_release)
    end

    it 'on day before arrest causes error' do
      new_incident.date_of_release = new_incident.date_of_arrest - 1
      expect(new_incident).to have(1).error_on(:date_of_release)
    end

    it 'on same day as arrest does not cause error' do
      new_incident.date_of_release = new_incident.date_of_arrest
      expect(new_incident).to have(0).error_on(:date_of_release)
    end

    it 'on day after arrest does not cause error' do
      new_incident.date_of_release = new_incident.date_of_arrest + 1
      expect(new_incident).to have(0).error_on(:date_of_release)
    end
  end

  describe 'that is most recent incident on prisoner' do
    it 'causes error if previous incident is not released' do
      previous_incident.date_of_release = nil
      previous_incident.save!
      expect(new_incident).to have(1).error_on(:date_of_arrest)
    end

    describe 'with previous incident that is released' do
      it "causes error if previous incident's date of release is after date of arrest" do
        previous_incident.date_of_release = new_incident.date_of_arrest + 1
        previous_incident.save!
        expect(new_incident).to have(1).error_on(:date_of_arrest)
      end

      it "does not cause error if previous incident's date of release is before date of arrest" do
        previous_incident.date_of_release = new_incident.date_of_arrest - 1
        previous_incident.save!
        expect(new_incident).to be_valid
      end

      it "does not cause error if previous incident's date of release is same day as date of arrest" do
        previous_incident.date_of_release = new_incident.date_of_arrest
        previous_incident.save!
        expect(new_incident).to be_valid
      end
    end
  end

  describe 'that is not most recent incident on prisoner' do
    before :example do
      subsequent_incident.save!
    end

    it 'causes error if date of release is not present' do
      new_incident.date_of_release = nil
      expect(new_incident).to have(1).error_on(:date_of_release)
    end

    describe 'and with date of release' do
      it "causes error if date of release is after next incident's date of arrest" do
        new_incident.date_of_release = subsequent_incident.date_of_arrest + 1
        expect(new_incident).to have(1).error_on(:date_of_release)
      end

      it "does not cause error if date of release is before next incident's date of arrest" do
        new_incident.date_of_release = subsequent_incident.date_of_arrest - 1
        expect(new_incident).to be_valid
      end

      it "does not cause error if date of release is same day as next incident's date of arrest" do
        new_incident.date_of_release = subsequent_incident.date_of_arrest
        expect(new_incident).to be_valid
      end
    end
  end

  describe 'with two earlier and two later incidents on prisoner' do
    before :example do
      previous_incident.save!
      earliest_incident.save!
      subsequent_incident.save!
      latest_incident.save!

      new_incident.date_of_release = new_incident.date_of_arrest + 1
    end

    it 'previous_incident gets incident with previous date of arrest' do
      expect(new_incident.previous_incident).to eq(previous_incident)
    end

    it 'subsequent_incidents gets incident with subsequent date of arrest' do
      expect(new_incident.subsequent_incident).to eq(subsequent_incident)
    end

    it 'is not only incident' do
      expect(new_incident.only_incident_on_prisoner?).to eq(false)
    end

    it 'is not the most recent incident' do
      expect(new_incident.most_recent_incident_on_prisoner?).to eq(false)
    end

    it 'is the most recent incident if date of arrest is changed to last' do
      new_incident.date_of_arrest = latest_incident.date_of_arrest + 365
      expect(new_incident.most_recent_incident_on_prisoner?).to eq(true)
    end
  end

  describe 'without other incidents on prisoner' do
    it 'is only incident when not saved' do
      expect(new_incident.only_incident_on_prisoner?).to eq(true)
    end

    it 'is only incident when saved' do
      new_incident.save!
      expect(new_incident.only_incident_on_prisoner?).to eq(true)
    end
  end
end
