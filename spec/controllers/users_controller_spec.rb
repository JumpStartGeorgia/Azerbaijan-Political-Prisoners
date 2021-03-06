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

RSpec.describe UsersController, type: :controller do
  let(:content_manager_role) { FactoryGirl.create(:role, name: 'content_manager') }
  let(:site_admin_role) { FactoryGirl.create(:role, name: 'site_admin') }
  let(:super_admin_role) { FactoryGirl.create(:role, name: 'super_admin') }

  let(:content_manager_user) { FactoryGirl.create(:user, role: content_manager_role) }
  let(:site_admin_user) { FactoryGirl.create(:user, role: site_admin_role) }
  let(:super_admin_user) { FactoryGirl.create(:user, role: super_admin_role) }

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    let(:valid_attributes) do
      FactoryGirl.attributes_for(:user, role_id: content_manager_role.id)
    end

    let(:invalid_attributes) do
      FactoryGirl.attributes_for(:user, email: '', role_id: content_manager_role.id)
    end

    before(:example) do
      sign_in :user, site_admin_user
    end

    it 'assigns all users as @users' do
      user = FactoryGirl.create(:user, valid_attributes)
      get :index, {}, valid_session
      expect(assigns(:users)).to eq([site_admin_user, user])
    end

    describe 'GET show' do
      it 'assigns the requested user as @user' do
        user = FactoryGirl.create(:user, valid_attributes)
        get :show, { id: user.to_param }, valid_session
        expect(assigns(:user)).to eq(user)
      end
    end

    describe 'GET new' do
      it 'assigns a new user as @user' do
        get :new, {}, valid_session
        expect(assigns(:user)).to be_a_new(User)
      end
    end

    describe 'GET edit' do
      it 'assigns the requested user as @user' do
        user = FactoryGirl.create(:user, valid_attributes)
        get :edit, { id: user.to_param }, valid_session
        expect(assigns(:user)).to eq(user)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new User' do
          expect do
            post :create, { user: valid_attributes }, valid_session
          end.to change(User, :count).by(1)
        end

        it 'assigns a newly created user as @user' do
          post :create, { user: valid_attributes }, valid_session
          expect(assigns(:user)).to be_a(User)
          expect(assigns(:user)).to be_persisted
        end

        it 'redirects to the created user' do
          post :create, { user: valid_attributes }, valid_session
          expect(response).to redirect_to(User.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user as @user' do
          post :create, { user: invalid_attributes }, valid_session
          expect(assigns(:user)).to be_a_new(User)
        end

        it "re-renders the 'new' template" do
          post :create, { user: invalid_attributes }, valid_session
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        let(:new_attributes) do
          FactoryGirl.build(:user, email: 'new@email.com').attributes
        end

        it 'updates the requested user' do
          user = FactoryGirl.create(:user, valid_attributes)
          put :update, { id: user.to_param, user: new_attributes }, valid_session
          user.reload
        end

        it 'assigns the requested user as @user' do
          user = FactoryGirl.create(:user, valid_attributes)
          put :update, { id: user.to_param, user: valid_attributes }, valid_session
          expect(assigns(:user)).to eq(user)
        end

        it 'redirects to the user' do
          user = FactoryGirl.create(:user, valid_attributes)
          put :update, { id: user.to_param, user: valid_attributes }, valid_session
          expect(response).to redirect_to(user)
        end
      end

      describe 'with invalid params' do
        it 'assigns the user as @user' do
          user = FactoryGirl.create(:user, valid_attributes)
          put :update, { id: user.to_param, user: invalid_attributes }, valid_session
          expect(assigns(:user)).to eq(user)
        end

        it "re-renders the 'edit' template" do
          user = FactoryGirl.create(:user, valid_attributes)
          put :update, { id: user.to_param, user: invalid_attributes }, valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested user' do
        user = FactoryGirl.create(:user, valid_attributes)

        expect do
          delete :destroy, { id: user.to_param }, valid_session
        end.to change(User, :count).by(-1)
      end

      it 'redirects to the users list' do
        user = FactoryGirl.create(:user, valid_attributes)

        delete :destroy, { id: user.to_param }, valid_session
        expect(response).to redirect_to(users_url)
      end
    end
  end

  describe 'role' do
    let(:super_admin_attributes) do
      FactoryGirl.attributes_for(:user, role_id: super_admin_role.id)
    end

    let(:site_admin_attributes) do
      FactoryGirl.attributes_for(:user, role_id: site_admin_role.id)
    end

    let(:content_manager_attributes) do
      FactoryGirl.attributes_for(:user, role_id: content_manager_role.id)
    end

    describe 'super admin' do
      before(:example) do
        sign_in :user, super_admin_user
      end

      it 'successfully updates a content manager to super admin role' do
        user = FactoryGirl.create(:user, content_manager_attributes)
        put :update, { id: user.to_param, user: super_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(user)
        expect(user.role.name).to eq('super_admin')
      end

      it 'successfully updates a content manager to site admin role' do
        user = FactoryGirl.create(:user, content_manager_attributes)
        put :update, { id: user.to_param, user: site_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(user)
        expect(user.role.name).to eq('site_admin')
      end

      it 'successfully updates a site admin to super admin role' do
        user = FactoryGirl.create(:user, site_admin_attributes)
        put :update, { id: user.to_param, user: super_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(user)
        expect(user.role.name).to eq('super_admin')
      end
    end

    describe 'site admin' do
      before(:example) do
        sign_in :user, site_admin_user
      end

      it 'fails to update another site admin to super admin role' do
        user = FactoryGirl.create(:user, site_admin_attributes)
        put :update, { id: user.to_param, user: super_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(user.role.name).to eq('site_admin')
      end

      it 'fails to update a content manager to super admin role' do
        user = FactoryGirl.create(:user, content_manager_attributes)
        put :update, { id: user.to_param, user: super_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(user.role.name).to eq('content_manager')
      end

      it 'successfully updates a content manager to site admin role' do
        user = FactoryGirl.create(:user, content_manager_attributes)
        put :update, { id: user.to_param, user: site_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(user)
        expect(user.role.name).to eq('site_admin')
      end

      it 'fails to update its own role to super_admin' do
        put :update, { id: site_admin_user.to_param, user: super_admin_attributes }, valid_session
        site_admin_user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(site_admin_user.role.name).to eq('site_admin')
      end
    end

    describe 'content manager' do
      before(:example) do
        sign_in :user, content_manager_user
      end

      it 'fails to update another content manager to super_admin role' do
        user = FactoryGirl.create(:user, content_manager_attributes)
        put :update, { id: user.to_param, user: super_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(user.role.name).to eq('content_manager')
      end

      it 'fails to update another content manager to site_admin role' do
        user = FactoryGirl.create(:user, content_manager_attributes)
        put :update, { id: user.to_param, user: site_admin_attributes }, valid_session
        user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(user.role.name).to eq('content_manager')
      end

      it 'fails to update its own role to site_admin' do
        put :update, { id: content_manager_user.to_param, user: site_admin_attributes }, valid_session
        content_manager_user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(content_manager_user.role.name).to eq('content_manager')
      end

      it 'fails to update its own role to super_admin' do
        put :update, { id: content_manager_user.to_param, user: super_admin_attributes }, valid_session
        content_manager_user.reload
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(t('shared.msgs.not_authorized'))
        expect(content_manager_user.role.name).to eq('content_manager')
      end
    end
  end
end
