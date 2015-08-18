require 'rails_helper'

RSpec.describe IncidentsController, type: :controller do
  let(:content_manager_role) { FactoryGirl.create(:role, name: 'content_manager') }
  let(:user) { FactoryGirl.create(:user, role: content_manager_role) }

  before(:example) do
    skip('Only fix incidents specs if we keep incidents in database')
    sign_in :user, user
  end

  # This should return the minimal set of attributes required to create a valid
  # Incident. As you add validations to Incident, be sure to
  # adjust the attributes here as well.

  let(:prisoner) { FactoryGirl.create(:prisoner) }

  let(:valid_attributes) do
    FactoryGirl.attributes_for(:incident, prisoner_id: prisoner.id)
  end

  let(:invalid_attributes) do
    FactoryGirl.attributes_for(:incident, prisoner_id: prisoner.id, date_of_arrest: nil)
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # IncidentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all incidents as @incidents' do
      incident = Incident.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:incidents)).to eq([incident])
    end
  end

  describe 'GET show' do
    it 'assigns the requested incident as @incident' do
      incident = Incident.create! valid_attributes
      get :show, { id: incident.to_param }, valid_session
      expect(assigns(:incident)).to eq(incident)
    end
  end

  describe 'GET new' do
    it 'assigns a new incident as @incident' do
      get :new, {}, valid_session
      expect(assigns(:incident)).to be_a_new(Incident)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested incident as @incident' do
      incident = Incident.create! valid_attributes
      get :edit, { id: incident.to_param }, valid_session
      expect(assigns(:incident)).to eq(incident)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Incident' do
        expect do
          post :create, { incident: valid_attributes }, valid_session
        end.to change(Incident, :count).by(1)
      end

      it 'assigns a newly created incident as @incident' do
        post :create, { incident: valid_attributes }, valid_session
        expect(assigns(:incident)).to be_a(Incident)
        expect(assigns(:incident)).to be_persisted
      end

      it 'redirects to the created incident' do
        post :create, { incident: valid_attributes }, valid_session
        expect(response).to redirect_to(Incident.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved incident as @incident' do
        post :create, { incident: invalid_attributes }, valid_session
        expect(assigns(:incident)).to be_a_new(Incident)
      end

      it "re-renders the 'new' template" do
        post :create, { incident: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_attributes) do
        FactoryGirl.attributes_for(:incident, date_of_arrest: valid_attributes[:date_of_arrest] + 1)
      end

      it 'updates the requested incident' do
        incident = Incident.create! valid_attributes
        put :update, { id: incident.to_param, incident: new_attributes }, valid_session
        incident.reload
      end

      it 'assigns the requested incident as @incident' do
        incident = Incident.create! valid_attributes
        put :update, { id: incident.to_param, incident: valid_attributes }, valid_session
        expect(assigns(:incident)).to eq(incident)
      end

      it 'redirects to the incident' do
        incident = Incident.create! valid_attributes
        put :update, { id: incident.to_param, incident: valid_attributes }, valid_session
        expect(response).to redirect_to(incident)
      end
    end

    describe 'with invalid params' do
      it 'assigns the incident as @incident' do
        incident = Incident.create! valid_attributes
        put :update, { id: incident.to_param, incident: invalid_attributes }, valid_session
        expect(assigns(:incident)).to eq(incident)
      end

      it "re-renders the 'edit' template" do
        incident = Incident.create! valid_attributes
        put :update, { id: incident.to_param, incident: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested incident' do
      incident = Incident.create! valid_attributes
      expect do
        delete :destroy, { id: incident.to_param }, valid_session
      end.to change(Incident, :count).by(-1)
    end

    it 'redirects to the incidents list' do
      incident = Incident.create! valid_attributes
      delete :destroy, { id: incident.to_param }, valid_session
      expect(response).to redirect_to(incidents_url)
    end
  end
end
