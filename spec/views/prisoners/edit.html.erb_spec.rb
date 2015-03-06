require 'rails_helper'

RSpec.describe "prisoners/edit", :type => :view do
  describe "for prisoner with no incidents" do
    it "only renders _incident_fields one time, in cocoon's data-association-insertion-template attribute" do
      @prisoner = assign(:prisoner, FactoryGirl.create(:prisoner))
      render

      expect(view).to render_template(:partial => "_incident_fields", :count => 1)
    end
  end

  describe 'for prisoner with two incidents' do
    before(:each) do
      @prisoner = assign(:prisoner, FactoryGirl.create(:prisoner_with_incidents))
      @prisoner.incidents << FactoryGirl.create(:incident, date_of_release: Date.new(2013, 1, 1))
      @prisoner.incidents << FactoryGirl.create(:incident, date_of_arrest: Date.new(2014, 1, 1))
    end

    it "renders _incident_fields partial for both incidents, plus one time in cocoon's data-association-insertion-template attribute" do
      render

      expect(view).to render_template(:partial => "_incident_fields", :count => 3)
    end
  end
end
