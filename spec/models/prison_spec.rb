require 'rails_helper'

RSpec.describe Prison, type: :model do
  let(:prison1) { FactoryGirl.create(:prison, name: 'prison') }

  it 'with non-unique name cannot be saved' do
    prison1.reload
    prison2 = FactoryGirl.build(:prison, name: 'prison')
    expect { prison2.save! }.to raise_error
  end

  describe 'when destroyed' do
    it 'is removed from associated incidents' do
      p1 = FactoryGirl.create(:prisoner)
      p1.incidents << FactoryGirl.create(:incident, prison: prison1)
      prison1.destroy
      p1.reload
      expect(p1.incidents.first.prison).to eq(nil)
    end
  end
end
