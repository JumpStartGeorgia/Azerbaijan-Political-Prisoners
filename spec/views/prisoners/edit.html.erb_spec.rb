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
      @prisoner = assign(:prisoner, FactoryGirl.create(:prisoner_with_incidents, incidents_count: 2))
    end

    it "renders the edit prisoner form" do
      render

      assert_select "form[action=?][method=?]", prisoner_path(@prisoner), "post" do
      end
    end

    it "renders _incident_fields partial for both incidents, plus one time in cocoon's data-association-insertion-template attribute" do
      render

      expect(view).to render_template(:partial => "_incident_fields", :count => 3)
    end
  end
end
