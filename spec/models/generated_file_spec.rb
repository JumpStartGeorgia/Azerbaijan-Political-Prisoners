require 'rails_helper'

RSpec.describe GeneratedFile, type: :model do
  describe 'regenerate method' do
    it 'works' do
      expect { GeneratedFile.regenerate }.not_to raise_error
    end
  end
end
