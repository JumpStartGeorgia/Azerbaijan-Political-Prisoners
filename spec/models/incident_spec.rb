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

    it 'today has no errors' do
      incident1.date_of_arrest = Date.today
      expect(incident1).to have(0).error_on(:date_of_arrest)
    end

    it 'tomorrow causes error' do
      incident1.date_of_arrest = Date.tomorrow
      expect(incident1).to have(1).error_on(:date_of_arrest)
    end
  end
end
