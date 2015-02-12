require 'rails_helper'

RSpec.describe "Prisoner display", :type => :feature do
  describe "renders the names of two prisoners" do

    let(:prisoner1) { FactoryGirl.create(:prisoner, name: 'pris#1') }
    let(:prisoner2) { FactoryGirl.create(:prisoner, name: 'pris#2') }

    it "that belong to the prison on the prison's show view" do
      prison = FactoryGirl.create(:prison)
      FactoryGirl.create(:incident, prisoner: prisoner1, prison: prison)
      FactoryGirl.create(:incident, prisoner: prisoner2, prison: prison)

      visit(prison_path(prison))
      expect(page).to have_text('pris#1')
      expect(page).to have_text('pris#2')
    end

    it "that belong to an article on the article's show view" do
      article = FactoryGirl.create(:article)
      incident1 = FactoryGirl.create(:incident, prisoner: prisoner1)
      incident1.articles << article
      incident2 = FactoryGirl.create(:incident, prisoner: prisoner2)
      incident2.articles << article

      visit(article_path(article))
      expect(page).to have_text('pris#1')
      expect(page).to have_text('pris#2')
    end
  end
end