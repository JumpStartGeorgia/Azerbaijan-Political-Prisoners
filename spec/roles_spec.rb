require 'rails_helper'
require 'cancan/matchers'

describe 'User' do

  let(:super_admin_role) { FactoryGirl.create(:role, name: 'super_admin') }
  let(:super_admin_user) { FactoryGirl.create(:user, role: super_admin_role) }
  let(:super_admin_user2) { FactoryGirl.create(:user, role: super_admin_role) }
  let(:site_admin_role) { FactoryGirl.create(:role, name: 'site_admin') }
  let(:site_admin_user) { FactoryGirl.create(:user, role: site_admin_role) }
  let(:site_admin_user2) { FactoryGirl.create(:user, role: site_admin_role) }
  let(:user_manager_role) { FactoryGirl.create(:role, name: 'user_manager') }
  let(:user_manager_user) { FactoryGirl.create(:user, role: user_manager_role) }
  let(:user_manager_user2) { FactoryGirl.create(:user, role: user_manager_role) }
  let(:visitor) { nil }

  describe 'when is super admin' do
    subject(:ability){ Ability.new(super_admin_user) }

    it 'can update super admin' do
      expect(ability).to be_able_to(:update, super_admin_user2)
    end

    it 'can update site admin' do
      expect(ability).to be_able_to(:update, site_admin_user)
    end

    it 'can update user manager' do
      expect(ability).to be_able_to(:update, user_manager_user)
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
    subject(:ability){ Ability.new(site_admin_user) }


    it 'cannot update super admin' do
      expect(ability).not_to be_able_to(:update, super_admin_user)
    end

    it 'can update site admin' do
      expect(ability).to be_able_to(:update, site_admin_user2)
    end

    it 'can update user manager' do
      expect(ability).to be_able_to(:update, user_manager_user)
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
    subject(:ability){ Ability.new(user_manager_user) }


    it 'cannot update super admin' do
      expect(ability).not_to be_able_to(:update, super_admin_user)
    end

    it 'cannot update site admin' do
      expect(ability).not_to be_able_to(:update, site_admin_user)
    end

    it 'can update user manager' do
      expect(ability).to be_able_to(:update, user_manager_user2)
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
    subject(:ability){ Ability.new(visitor) }

    it 'cannot update super admin' do
      expect(ability).not_to be_able_to(:update, super_admin_user)
    end

    it 'cannot update site admin' do
      expect(ability).not_to be_able_to(:update, site_admin_user)
    end

    it 'cannot update user manager' do
      expect(ability).not_to be_able_to(:update, user_manager_user)
    end

    it 'cannot manage content' do
      expect(ability).not_to be_able_to(:manage, Prisoner.new)
      expect(ability).not_to be_able_to(:manage, Prison.new)
      expect(ability).not_to be_able_to(:manage, Article.new)
      expect(ability).not_to be_able_to(:manage, Tag.new)
      expect(ability).not_to be_able_to(:manage, CriminalCode.new)
    end
  end
end