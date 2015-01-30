require 'rails_helper'

RSpec.describe "The article show view", :type => :feature do
  it "renders the names of two prisoners who have incidents that have this article" do
    article = FactoryGirl.create(:article)
    prisoner1 = FactoryGirl.create(:prisoner, name: 'pris#1')
    prisoner2 = FactoryGirl.create(:prisoner, name: 'pris#2')
    FactoryGirl.create(:incident, prisoner: prisoner1, articles: [article])
    FactoryGirl.create(:incident, prisoner: prisoner2, articles: [article])

    visit("/articles")
    visit(article_path(article))
    expect(page).to have_text('pris#1')
    expect(page).to have_text('pris#2')
  end
end