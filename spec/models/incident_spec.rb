require 'rails_helper'

RSpec.describe Incident, type: :model do
  let(:incident1) { FactoryGirl.create(:incident) }

  it 'is valid with valid attributes' do
    expect(incident1).to be_valid
  end

  describe 'prisoner' do
    it 'is required' do
      incident1.prisoner = nil
      expect(incident1).to have(1).error_on(:prisoner)
    end
  end

  describe 'date of arrest' do
    it 'is required' do
      incident1.date_of_arrest = nil
      expect(incident1).to have(1).error_on(:date_of_arrest)
    end

    it 'yesterday does not cause error' do
      incident1.date_of_arrest = Date.yesterday
      expect(incident1).to have(0).error_on(:date_of_arrest)
    end

    it 'today does not cause error' do
      incident1.date_of_arrest = Date.today
      expect(incident1).to have(0).error_on(:date_of_arrest)
    end

    it 'tomorrow causes error' do
      incident1.date_of_arrest = Date.tomorrow
      expect(incident1).to have(1).error_on(:date_of_arrest)
    end
  end

  describe 'date of release' do
    it 'yesterday does not cause error' do
      incident1.date_of_release = Date.yesterday
      expect(incident1).to have(0).error_on(:date_of_release)
    end

    it 'today does not cause error' do
      incident1.date_of_release = Date.today
      expect(incident1).to have(0).error_on(:date_of_release)
    end

    it 'tomorrow causes error' do
      incident1.date_of_release = Date.tomorrow
      expect(incident1).to have(1).error_on(:date_of_release)
    end

    it 'on day before arrest causes error' do
      incident1.date_of_release = incident1.date_of_arrest - 1
      expect(incident1).to have(1).error_on(:date_of_release)
    end

    it 'on same day as arrest does not cause error' do
      incident1.date_of_release = incident1.date_of_arrest
      expect(incident1).to have(0).error_on(:date_of_release)
    end

    it 'on day after arrest does not cause error' do
      incident1.date_of_release = incident1.date_of_arrest + 1
      expect(incident1).to have(0).error_on(:date_of_release)
    end
  end

  describe 'that is most recent incident on prisoner' do
    it 'causes error if previous incident is not released' do

    end

    describe 'with previous incident that is released' do
      it "causes error if previous incident's date of release is after date of arrest" do

      end

      it "does not cause error if previous incident's date of release is before date of arrest" do

      end
    end
  end

  describe 'that is not most recent incident on prisoner' do
    it 'causes error if date of release is not present' do

    end

    describe 'and with date of release' do
      it "causes error if date of release is after next incident's date of arrest" do

      end

      it "does not cause error if date of release is before next incident's date of arrest" do

      end
    end
  end
end
