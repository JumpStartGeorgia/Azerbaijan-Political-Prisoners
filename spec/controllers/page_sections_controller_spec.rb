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

RSpec.describe PageSectionsController, type: :controller do
  let(:super_admin_role) { FactoryGirl.create(:role, name: 'super_admin') }
  let(:user) { FactoryGirl.create(:user, role: super_admin_role) }

  before(:example) do
    sign_in :user, user
  end

  # This should return the minimal set of attributes required to create a valid
  # Page Section. As you add validations to Page Section, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    FactoryGirl.build(:page_section, name: 'app_intro').attributes
  end

  let(:invalid_attributes) do
    FactoryGirl.build(:page_section, name: '').attributes
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PageSectionsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all page sections as @page_sections' do
      page_section = PageSection.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:page_sections)).to eq([page_section])
    end
  end

  describe 'GET show' do
    it 'assigns the requested page section as @page_section' do
      page_section = PageSection.create! valid_attributes
      get :show, { id: page_section.to_param }, valid_session
      expect(assigns(:page_section)).to eq(page_section)
    end
  end

  describe 'GET new' do
    it 'assigns a new page section as @page_section' do
      get :new, {}, valid_session
      expect(assigns(:page_section)).to be_a_new(PageSection)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested page section as @page_section' do
      page_section = PageSection.create! valid_attributes
      get :edit, { id: page_section.to_param }, valid_session
      expect(assigns(:page_section)).to eq(page_section)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new page section' do
        expect do
          post :create, { page_section: valid_attributes }, valid_session
        end.to change(PageSection, :count).by(1)
      end

      it 'assigns a newly created page_section as @page_section' do
        post :create, { page_section: valid_attributes }, valid_session
        expect(assigns(:page_section)).to be_a(PageSection)
        expect(assigns(:page_section)).to be_persisted
      end

      it 'redirects to the created page section' do
        post :create, { page_section: valid_attributes }, valid_session
        expect(response).to redirect_to(PageSection.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved page section as @page_section' do
        post :create, { page_section: invalid_attributes }, valid_session
        expect(assigns(:page_section)).to be_a_new(PageSection)
      end

      it "re-renders the 'new' template" do
        post :create, { page_section: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_name) { 'project_description' }
      let(:new_attributes) do
        FactoryGirl.build(:page_section, name: new_name).attributes
      end

      it 'updates the requested page section' do
        page_section = PageSection.create! valid_attributes
        put :update, { id: page_section.to_param, page_section: new_attributes }, valid_session
        page_section.reload
        expect(page_section.name).to eq(new_name)
      end

      it 'assigns the requested page section as @page_section' do
        page_section = PageSection.create! valid_attributes
        put :update, { id: page_section.to_param, page_section: valid_attributes }, valid_session
        expect(assigns(:page_section)).to eq(page_section)
      end

      it 'redirects to the page section' do
        page_section = PageSection.create! valid_attributes
        put :update, { id: page_section.to_param, page_section: valid_attributes }, valid_session
        expect(response).to redirect_to(page_section)
      end
    end

    describe 'with invalid params' do
      it 'assigns the page section as @page_section' do
        page_section = PageSection.create! valid_attributes
        put :update, { id: page_section.to_param, page_section: invalid_attributes }, valid_session
        expect(assigns(:page_section)).to eq(page_section)
      end

      it "re-renders the 'edit' template" do
        page_section = PageSection.create! valid_attributes
        put :update, { id: page_section.to_param, page_section: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested page section' do
      page_section = PageSection.create! valid_attributes
      expect do
        delete :destroy, { id: page_section.to_param }, valid_session
      end.to change(PageSection, :count).by(-1)
    end

    it 'redirects to the page sections list' do
      page_section = PageSection.create! valid_attributes
      delete :destroy, { id: page_section.to_param }, valid_session
      expect(response).to redirect_to(page_sections_url)
    end
  end
end