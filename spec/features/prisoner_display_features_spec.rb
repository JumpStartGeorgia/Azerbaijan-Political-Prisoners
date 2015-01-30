require 'rails_helper'

RSpec.describe "Prisoner display", :type => :feature do
  describe "renders the names of two prisoners" do

    let(:prisoner1) { FactoryGirl.create(:prisoner, name: 'pris#1') }
    let(:prisoner2) { FactoryGirl.create(:prisoner, name: 'pris#2') }

    it "on the prison show view who have incidents that belong to the prison" do
      prison = FactoryGirl.create(:prison)
      FactoryGirl.create(:incident, prisoner: prisoner1, prison: prison)
      FactoryGirl.create(:incident, prisoner: prisoner2, prison: prison)

      visit(prison_path(prison))
      expect(page).to have_text('pris#1')
      expect(page).to have_text('pris#2')
    end

    it "on the article show view who have incidents that have the article" do
      article = FactoryGirl.create(:article)
      FactoryGirl.create(:incident, prisoner: prisoner1, articles: [article])
      FactoryGirl.create(:incident, prisoner: prisoner2, articles: [article])

      visit(article_path(article))
      expect(page).to have_text('pris#1')
      expect(page).to have_text('pris#2')
    end

    it "on the subtype show view who have incidents that have the subtype" do
      subtype = FactoryGirl.create(:subtype)
      FactoryGirl.create(:incident, prisoner: prisoner1, subtype: subtype)
      FactoryGirl.create(:incident, prisoner: prisoner2, subtype: subtype)

      visit(subtype_path(subtype))
      expect(page).to have_text('pris#1')
      expect(page).to have_text('pris#2')
    end

    it "on the type show view who have incidents that have the type" do
      type = FactoryGirl.create(:type)
      FactoryGirl.create(:incident, prisoner: prisoner1, type: type)
      FactoryGirl.create(:incident, prisoner: prisoner2, type: type)

      visit(type_path(type))
      expect(page).to have_text('pris#1')
      expect(page).to have_text('pris#2')
    end
  end
end