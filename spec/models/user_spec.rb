require 'rails_helper'

RSpec.describe User, :type => :model do
  it "with non-unique email cannot be saved" do
    FactoryGirl.create(:user, email: 'unique@azeri.com')
    user2 = FactoryGirl.build(:user, email: 'unique@azeri.com')
    expect { user2.save! }.to raise_error
  end

  describe "with email, password and role" do
    it "is valid" do
      user_manager_user = FactoryGirl.build(:user)
      expect { user_manager_user.save! }.not_to raise_error
    end
  end

  describe "with email, password and no role" do
    it "is not valid" do
      user_manager_user = FactoryGirl.build(:user, role: nil)
      expect { user_manager_user.save! }.to raise_error
    end
  end

  describe "with email, role and no password" do
    it "is not valid" do
      user_manager_user = FactoryGirl.build(:user, password: '')
      expect { user_manager_user.save! }.to raise_error
    end
  end

  describe "with password, role and no email" do
    it "is not valid" do
      user_manager_user = FactoryGirl.build(:user, email: '')
      expect { user_manager_user.save! }.to raise_error
    end
  end
end
