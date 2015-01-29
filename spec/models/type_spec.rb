require 'rails_helper'

RSpec.describe Type, :type => :model do
  it "with name that already exists in database is invalid" do
    FactoryGirl.create(:type, name: 'TypeName')
    type2 = FactoryGirl.build(:type, name: 'TypeName')
    expect { type2.save! }.to raise_error
  end
end