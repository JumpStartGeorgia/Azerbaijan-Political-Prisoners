require 'rails_helper'
require 'cancan/matchers'

describe 'Admin' do
  describe 'when is super admin' do
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
      skip()
    end
  end

  describe 'when is site admin' do
    it 'can create user manager' do
      skip()
    end

    it 'can manage content' do
      skip()
    end
  end

  describe 'when is user manager' do
    it 'can manage content' do
      skip()
    end
  end
end