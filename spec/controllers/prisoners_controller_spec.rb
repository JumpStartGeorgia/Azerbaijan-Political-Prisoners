require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe PrisonersController, type: :controller do
  let(:content_manager_role) { FactoryGirl.create(:role, name: 'content_manager') }
  let(:user) { FactoryGirl.create(:user, role: content_manager_role) }

  before(:example) do
    sign_in :user, user
  end

  # This should return the minimal set of attributes required to create a valid
  # Prisoner. As you add validations to Prisoner, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    FactoryGirl.build(:prisoner, name: 'MyName').attributes
  end

  let(:invalid_attributes) do
    FactoryGirl.build(:prisoner, name: '').attributes
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PrisonersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all prisoners as @prisoners' do
      prisoner = Prisoner.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:prisoners)).to eq([prisoner])
    end
  end

  describe 'GET show' do
    it 'assigns the requested prisoner as @prisoner' do
      prisoner = Prisoner.create! valid_attributes
      get :show, { id: prisoner.to_param }, valid_session
      expect(assigns(:prisoner)).to eq(prisoner)
    end
  end

  describe 'GET new' do
    it 'assigns a new prisoner as @prisoner' do
      get :new, {}, valid_session
      expect(assigns(:prisoner)).to be_a_new(Prisoner)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested prisoner as @prisoner' do
      prisoner = Prisoner.create! valid_attributes
      get :edit, { id: prisoner.to_param }, valid_session
      expect(assigns(:prisoner)).to eq(prisoner)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Prisoner' do
        expect do
          post :create, { prisoner: valid_attributes }, valid_session
        end.to change(Prisoner, :count).by(1)
      end

      it 'assigns a newly created prisoner as @prisoner' do
        post :create, { prisoner: valid_attributes }, valid_session
        expect(assigns(:prisoner)).to be_a(Prisoner)
        expect(assigns(:prisoner)).to be_persisted
      end

      it 'redirects to the created prisoner' do
        post :create, { prisoner: valid_attributes }, valid_session
        expect(response).to redirect_to(Prisoner.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved prisoner as @prisoner' do
        post :create, { prisoner: invalid_attributes }, valid_session
        expect(assigns(:prisoner)).to be_a_new(Prisoner)
      end

      it "re-renders the 'new' template" do
        post :create, { prisoner: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_attributes) do
        FactoryGirl.build(:prisoner, name: 'NewName').attributes
      end

      it 'updates the requested prisoner' do
        prisoner = Prisoner.create! valid_attributes
        put :update, { id: prisoner.to_param, prisoner: new_attributes }, valid_session
        prisoner.reload
      end

      it 'assigns the requested prisoner as @prisoner' do
        prisoner = Prisoner.create! valid_attributes
        put :update, { id: prisoner.to_param, prisoner: valid_attributes }, valid_session
        expect(assigns(:prisoner)).to eq(prisoner)
      end

      it 'redirects to the prisoner' do
        prisoner = Prisoner.create! valid_attributes
        put :update, { id: prisoner.to_param, prisoner: valid_attributes }, valid_session
        expect(response).to redirect_to(prisoner)
      end
    end

    describe 'with invalid params' do
      it 'assigns the prisoner as @prisoner' do
        prisoner = Prisoner.create! valid_attributes
        put :update, { id: prisoner.to_param, prisoner: invalid_attributes }, valid_session
        expect(assigns(:prisoner)).to eq(prisoner)
      end

      it "re-renders the 'edit' template" do
        prisoner = Prisoner.create! valid_attributes
        put :update, { id: prisoner.to_param, prisoner: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested prisoner' do
      prisoner = Prisoner.create! valid_attributes
      expect do
        delete :destroy, { id: prisoner.to_param }, valid_session
      end.to change(Prisoner, :count).by(-1)
    end

    it 'redirects to the prisoners list' do
      prisoner = Prisoner.create! valid_attributes
      delete :destroy, { id: prisoner.to_param }, valid_session
      expect(response).to redirect_to(prisoners_url)
    end
  end
end
