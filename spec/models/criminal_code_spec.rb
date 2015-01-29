require 'rails_helper'

RSpec.describe CriminalCode, :type => :model do
  it "with non-unique name cannot be saved" do
    FactoryGirl.create(:criminal_code, name: '1960')
    criminalCode2 = FactoryGirl.build(:criminal_code, name: '1960')

    expect { criminalCode2.save! }.to raise_error
  end
end