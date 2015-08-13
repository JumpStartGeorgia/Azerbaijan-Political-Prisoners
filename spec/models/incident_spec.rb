require 'rails_helper'

RSpec.describe Incident, type: :model do
  let(:new_incident) { FactoryGirl.build(:incident) }

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
    let(:previous_incident) do
      FactoryGirl.create(
        :incident,
        date_of_arrest: new_incident.date_of_arrest - 365
      )
    end

    it 'causes error if previous incident is not released' do
      previous_incident.date_of_release = nil
      expect(new_incident).to have(1).error_on(:date_of_arrest)
    end

    describe 'with previous incident that is released' do
      it "causes error if previous incident's date of release is after date of arrest" do
        previous_incident.date_of_release = new_incident.date_of_arrest + 1
        expect(new_incident).to have(1).error_on(:date_of_arrest)
      end

      it "does not cause error if previous incident's date of release is before date of arrest" do
        previous_incident.date_of_release = new_incident.date_of_arrest - 1
        expect(new_incident).to be_valid
      end

      it "does not cause error if previous incident's date of release is same day as date of arrest" do
        previous_incident.date_of_release = new_incident.date_of_arrest
        expect(new_incident).to be_valid
      end
    end
  end

  describe 'that is not most recent incident on prisoner' do
    let(:subsequent_incident) do
      FactoryGirl.create(
        :incident,
        date_of_arrest: new_incident.date_of_arrest + 365
      )
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
end
