require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:article1) { FactoryGirl.create(:article) }
  let(:article2) { FactoryGirl.create(:article) }

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
end
