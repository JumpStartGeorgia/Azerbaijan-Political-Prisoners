require 'rails_helper'
require 'cancan/matchers'

describe 'User' do
  subject(:ability){ Ability.new(user) }

  describe 'when is super admin' do
    let(:super_admin_role) { FactoryGirl.create(:role, name: 'super_admin') }
    let(:user) { FactoryGirl.create(:user, role: super_admin_role) }

    it 'can create super admin' do
      skip()
    end

    it 'can create site admin' do
      skip()
    end

    it 'can create user manager' do
      skip()
    end

    it 'can manage content' do
      expect(ability).to be_able_to(:manage, Prisoner.new)
      expect(ability).to be_able_to(:manage, Prison.new)
      expect(ability).to be_able_to(:manage, Article.new)
      expect(ability).to be_able_to(:manage, Tag.new)
      expect(ability).to be_able_to(:manage, CriminalCode.new)
    end
  end

  describe 'when is site admin' do
    let(:site_admin_role) { FactoryGirl.create(:role, name: 'site_admin') }
    let(:user) { FactoryGirl.create(:user, role: site_admin_role) }

    it 'cannot create super admin' do
      skip()
    end

    it 'cannot create site admin' do
      skip()
    end

    it 'can create user manager' do
      skip()
    end

    it 'can manage content' do
      expect(ability).to be_able_to(:manage, Prisoner.new)
      expect(ability).to be_able_to(:manage, Prison.new)
      expect(ability).to be_able_to(:manage, Article.new)
      expect(ability).to be_able_to(:manage, Tag.new)
      expect(ability).to be_able_to(:manage, CriminalCode.new)
    end
  end

  describe 'when is user manager' do
    let(:user_manager_role) { FactoryGirl.create(:role, name: 'user_manager') }
    let(:user) { FactoryGirl.create(:user, role: user_manager_role) }

    it 'cannot create super admin' do
      skip()
    end

    it 'cannot create site admin' do
      skip()
    end

    it 'cannot create user manager' do
      skip()
    end

    it 'can manage content' do
      expect(ability).to be_able_to(:manage, Prisoner.new)
      expect(ability).to be_able_to(:manage, Prison.new)
      expect(ability).to be_able_to(:manage, Article.new)
      expect(ability).to be_able_to(:manage, Tag.new)
      expect(ability).to be_able_to(:manage, CriminalCode.new)
    end
  end

  describe 'when is not logged in' do
    let(:user) { nil }

    it 'cannot create super admin' do
      skip()
    end

    it 'cannot create site admin' do
      skip()
    end

    it 'cannot create user manager' do
      skip()
    end

    it 'cannot manage content' do
      expect(ability).to_not be_able_to(:manage, Prisoner.new)
      expect(ability).to_not be_able_to(:manage, Prison.new)
      expect(ability).to_not be_able_to(:manage, Article.new)
      expect(ability).to_not be_able_to(:manage, Tag.new)
      expect(ability).to_not be_able_to(:manage, CriminalCode.new)
    end
  end
end