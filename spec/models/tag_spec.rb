require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag1) { FactoryGirl.create(:tag) }

  it 'should have a description when saved with a description' do
    tag1.description = 'The tag to end all tags'
    tag1.save
    expect(tag1.description).to eq('The tag to end all tags')
  end

  it 'with non-unique name cannot be saved' do
    FactoryGirl.create(:tag, name: 'Unique name')
    tag2 = FactoryGirl.build(:tag, name: 'Unique name')
    expect { tag2.save! }.to raise_error
  end
end
