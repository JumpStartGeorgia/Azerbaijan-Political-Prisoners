require 'rails_helper'
require 'cancan/matchers'

describe 'User' do
  let(:super_admin_user) { FactoryGirl.create(:user, role: Role.find_by_name('super_admin')) }
  let(:super_admin_user2) { FactoryGirl.create(:user, role: Role.find_by_name('super_admin')) }
  let(:site_admin_user) { FactoryGirl.create(:user, role: Role.find_by_name('site_admin')) }
  let(:site_admin_user2) { FactoryGirl.create(:user, role: Role.find_by_name('site_admin')) }
  let(:content_manager_user) { FactoryGirl.create(:user, role: Role.find_by_name('content_manager')) }
  let(:content_manager_user2) { FactoryGirl.create(:user, role: Role.find_by_name('content_manager')) }
  let(:visitor) { nil }

  describe 'when is super admin' do
    subject(:ability) { Ability.new(super_admin_user) }

    it 'can update super admin' do
      expect(ability).to be_able_to(:update, super_admin_user2)
    end

    it 'can update site admin' do
      expect(ability).to be_able_to(:update, site_admin_user)
    end

    it 'can update content manager' do
      expect(ability).to be_able_to(:update, content_manager_user)
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
    subject(:ability) { Ability.new(site_admin_user) }

    it 'cannot update super admin' do
      expect(ability).not_to be_able_to(:update, super_admin_user)
    end

    it 'can update site admin' do
      expect(ability).to be_able_to(:update, site_admin_user2)
    end

    it 'can update content manager' do
      expect(ability).to be_able_to(:update, content_manager_user)
    end

    it 'can manage content' do
      expect(ability).to be_able_to(:manage, Prisoner.new)
      expect(ability).to be_able_to(:manage, Prison.new)
      expect(ability).to be_able_to(:manage, Article.new)
      expect(ability).to be_able_to(:manage, Tag.new)
      expect(ability).to be_able_to(:manage, CriminalCode.new)
    end
  end

  describe 'when is content manager' do
    subject(:ability) { Ability.new(content_manager_user) }
    it 'cannot read users' do
      expect(ability).not_to be_able_to(:read, User.new)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User.new)
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
    subject(:ability) { Ability.new(visitor) }

    it 'cannot update super admin' do
      expect(ability).not_to be_able_to(:update, super_admin_user)
    end

    it 'cannot update site admin' do
      expect(ability).not_to be_able_to(:update, site_admin_user)
    end

    it 'cannot update content manager' do
      expect(ability).not_to be_able_to(:update, content_manager_user)
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
