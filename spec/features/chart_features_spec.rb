require 'rails_helper'

RSpec.describe 'Chart', type: :feature, js: true do
  describe 'imprisoned count timeline' do
    it 'shows up on root page' do
      visit root_path
      click_on 'Political Prisoners Watch'
      find('#imprisoned-count-timeline').find('.highcharts-container')
    end
  end

  describe 'prison prisoner counts' do
    it 'shows up on root page' do
      visit root_path
      click_on 'Political Prisoners Watch'
      find('#prison-prisoner-counts').find('.highcharts-container')
    end
  end

  describe 'article sentence counts' do
    it 'shows up on root page' do
      visit root_path
      click_on 'Political Prisoners Watch'
      find('#top-10-charge-counts').find('.highcharts-container')
    end
  end
end
