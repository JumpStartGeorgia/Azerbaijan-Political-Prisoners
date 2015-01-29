require 'rails_helper'

RSpec.describe Subtype, :type => :model do
  let(:type) { FactoryGirl.create(:type, name: 'type1') }

  before(:example) do
    FactoryGirl.create(:subtype, name: "subtype1", type: type)
  end

  it "with unique type and non-unique name can be saved" do
    type2 = FactoryGirl.create(:type, name: 'type2')
    subtype2 = FactoryGirl.build(:subtype, name: "subtype1", type: type2)

    expect { subtype2.save! }.not_to raise_error
  end

  it "with unique name and non-unique type can be saved" do
    subtype2 = FactoryGirl.build(:subtype, name: "subtype2", type: type)

    expect { subtype2.save! }.not_to raise_error
  end

  it "with non-unique name and non-unique type cannot be saved" do
    subtype2 = FactoryGirl.build(:subtype, name: "subtype1", type: type)

    expect { subtype2.save! }.to raise_error
  end
end