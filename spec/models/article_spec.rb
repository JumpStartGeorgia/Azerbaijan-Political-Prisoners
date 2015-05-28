require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:criminal_code) { FactoryGirl.create(:criminal_code, name: 'cri1') }

  before(:example) do
    FactoryGirl.create(:article, number: '101.2', criminal_code: criminal_code)
  end

  it 'with unique criminal code and non-unique number can be saved' do
    criminal_code2 = FactoryGirl.create(:criminal_code, name: 'cri2')
    article2 = FactoryGirl.build(:article, number: '101.2', criminal_code: criminal_code2)

    expect { article2.save! }.not_to raise_error
  end

  it 'with unique number and non-unique criminal code can be saved' do
    article2 = FactoryGirl.build(:article, number: '101.3', criminal_code: criminal_code)

    expect { article2.save! }.not_to raise_error
  end

  it 'with non-unique number and non-unique criminal code cannot be saved' do
    article2 = FactoryGirl.build(:article, number: '101.2', criminal_code: criminal_code)

    expect { article2.save! }.to raise_error
  end
end
