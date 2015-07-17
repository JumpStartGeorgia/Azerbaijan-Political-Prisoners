require 'rails_helper'

RSpec.describe PageSection, type: :model do
  let (:page_section1) do
    FactoryGirl.build(:page_section,
                      name: 'app_intro')
  end
  let (:page_section2) do
    FactoryGirl.build(:page_section,
                      name: 'project_description')
  end

  describe 'cannot be saved' do
    it 'without name' do
      page_section1.name = ''
      expect { page_section1.save! }.to raise_error
    end

    it 'with same name' do
      page_section1.save!
      page_section2.name = page_section1.name
      expect { page_section2.save! }.to raise_error
    end
  end
end
