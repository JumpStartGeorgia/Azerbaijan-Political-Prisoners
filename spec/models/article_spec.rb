require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:article1) { FactoryGirl.create(:article) }
  let(:article2) { FactoryGirl.create(:article) }

  let(:prisoner1_with_article1) do
    p = FactoryGirl.create(:prisoner)
    p.incidents << FactoryGirl.create(:incident, articles: [article1, article2])
    p
  end

  let(:prisoner2_with_article2) do
    p = FactoryGirl.create(:prisoner)
    p.incidents << FactoryGirl.create(:incident, articles: [article2])
    p
  end

  it 'with unique criminal code and non-unique number can be saved' do
    article2.number = article1.number

    expect { article2.save! }.not_to raise_error
  end

  it 'with unique number and non-unique criminal code can be saved' do
    article2.criminal_code = article1.criminal_code

    expect { article2.save! }.not_to raise_error
  end

  it 'with non-unique number and non-unique criminal code cannot be saved' do
    article2.number = article1.number
    article2.criminal_code = article1.criminal_code

    expect { article2.save! }.to raise_error
  end

  describe 'incident counts json data' do
    let(:json_data) { Article.charge_counts_chart_data }

    describe 'with two articles (1 charge and 2 charges)' do
      before(:example) do
        prisoner1_with_article1.save!
        prisoner2_with_article2.save!
      end

      it 'gets 1 charge for first article' do
        expect(json_data.find { |x| x[:number] == article1.number }[:y]).to eq(1)
      end

      it 'gets 2 charges for second article' do
        expect(json_data.find { |x| x[:number] == article2.number }[:y]).to eq(2)
      end

      describe 'with az locale' do
        describe 'with one code name translated and one not' do
          before(:example) do
            I18n.locale = :az

            code = article2.criminal_code
            code.name_az = 'az code name'
            code.save!
          end

          it 'uses Azeri code name in summary' do
            expect(json_data.find { |x| x[:number] == article2.number }[:summary].include? article2.criminal_code.name_en)
          end

          it 'uses English code name in summary as fallback' do
            expect(json_data.find { |x| x[:number] == article1.number }[:summary].include? article1.criminal_code.name_en)
          end
        end
      end
    end
  end
end
