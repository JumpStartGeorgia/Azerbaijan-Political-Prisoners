require 'rails_helper'

RSpec.describe 'Incidents to Tags relationship', type: :model do
  let(:tag1) { FactoryGirl.create(:tag) }
  let(:tag2) { FactoryGirl.create(:tag) }
  let(:incident1) { FactoryGirl.create(:incident) }
  let(:incident2) { FactoryGirl.create(:incident) }

  it 'should recognize when a tag has no incidents' do
    expect(tag1.incidents.size).to eq(0)
  end

  it 'should recognize when a tag has two incidents' do
    tag2.incidents << incident2
    tag2.incidents << incident1
    expect(tag2.incidents.size).to eq(2)
  end

  it 'should recognize when an incident has two tags' do
    incident1.tags << tag1
    incident1.tags << tag2
    expect(incident1.tags.size).to eq(2)
  end

  it 'should recognize that an incident has two tags after saving the incident to two tags' do
    tag1.incidents << incident1
    tag2.incidents << incident1
    expect(incident1.tags.size).to eq(2)
  end

  it 'should recognize when a tag has two incidents after saving the tag to two incidents' do
    incident1.tags << tag1
    incident2.tags << tag1
    expect(tag1.incidents.size).to eq(2)
  end
end
