require 'rails_helper'

RSpec.describe Prison, type: :model do
  it 'with non-unique name cannot be saved' do
    FactoryGirl.create(:prison, name: 'prison')
    prison2 = FactoryGirl.build(:prison, name: 'prison')
    expect { prison2.save! }.to raise_error
  end
end
