require 'rails_helper'

RSpec.describe Prison, type: :model do
  let!(:prison1) { FactoryGirl.create(:prison, name_en: 'prison1') }
  let!(:prison2) { FactoryGirl.create(:prison, name_en: 'prison2') }
  let(:prisoner1) { FactoryGirl.create(:prisoner, name: 'prisoner1') }
  let(:prisoner2) { FactoryGirl.create(:prisoner, name: 'prisoner2') }

  it 'with non-unique name cannot be saved' do
    prison1.reload
    prison2 = FactoryGirl.build(:prison, name: 'prison1')
    expect { prison2.save! }.to raise_error
  end

  describe 'when destroyed' do
    it 'is removed from associated incidents' do
      p1 = FactoryGirl.create(:prisoner)
      p1.incidents << FactoryGirl.create(:incident, prison: prison1)
      p1.save!
      prison1.destroy
      p1.reload
      expect(p1.incidents.first.prison).to eq(nil)
    end
  end

  describe 'prisoner counts json' do
    let(:json_data) { Prison.current_prisoner_counts[:data] }

    describe 'has correct prisoner counts' do
      describe 'with two prisons' do
        describe 'containing one imprisoned prisoner each' do
          it 'with one incident each' do
            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison1)
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison2)

            expect(json_data.select { |x| x[:name] == 'prison1' }[0][:y]).to eq(1)
            expect(json_data.select { |x| x[:name] == 'prison2' }[0][:y]).to eq(1)
          end

          it 'with two incidents each' do
            # old incidents - should not be counted
            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison1, date_of_arrest: Date.new(2009, 8, 15), date_of_release: Date.new(2013, 7, 25))
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison2, date_of_arrest: Date.new(2010, 1, 20), date_of_release: Date.new(2011, 1, 1))

            # new incidents - should be counted
            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison1, date_of_arrest: 10.days.ago)
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison2, date_of_arrest: 10.days.ago)

            expect(json_data.select { |x| x[:name] == 'prison1' }[0][:y]).to eq(1)
            expect(json_data.select { |x| x[:name] == 'prison2' }[0][:y]).to eq(1)
          end
        end

        describe 'one containing two imprisoned prisoners and one no prisoners' do
          it 'with one incident each' do
            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison1)
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison1)

            expect(json_data.select { |x| x[:name] == 'prison1' }[0][:y]).to eq(2)
            expect(json_data.select { |x| x[:name] == 'prison2' }).to eq([])
          end

          it 'with two incidents each' do
            # old incidents - should not be counted
            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison2, date_of_arrest: Date.new(2009, 8, 15), date_of_release: Date.new(2013, 7, 25))
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison2, date_of_arrest: Date.new(2010, 1, 20), date_of_release: Date.new(2011, 1, 1))

            # new incidents - should be counted
            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison1, date_of_arrest: 10.days.ago)
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison1, date_of_arrest: 10.days.ago)

            expect(json_data.select { |x| x[:name] == 'prison1' }[0][:y]).to eq(2)
            expect(json_data.select { |x| x[:name] == 'prison2' }).to eq([])
          end
        end
      end
    end

    describe 'has correct prison name translations' do
      describe 'on az locale' do
        describe 'with two prisons' do
          it 'one with az name translation and one without' do
            I18n.locale = :az
            prison1.name_az = 'Azeri name!'
            prison1.save!

            prisoner1.incidents << FactoryGirl.create(:incident, prison: prison1, date_of_arrest: 10.days.ago)
            prisoner2.incidents << FactoryGirl.create(:incident, prison: prison2, date_of_arrest: 10.days.ago)

            expect(json_data.count { |x| x[:name] == prison1.name_az }).to eq(1)
            expect(json_data.count { |x| x[:name] == prison2.name_en }).to eq(1)
          end
        end
      end
    end
  end
end
