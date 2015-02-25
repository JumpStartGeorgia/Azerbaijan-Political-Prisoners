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

RSpec.describe UsersController, :type => :controller do

  let(:user_manager_user) { FactoryGirl.create(:user, role: Role.find_by_name('user_manager')) }
  let(:site_admin_user) { FactoryGirl.create(:user, role: Role.find_by_name('site_admin')) }
  let(:super_admin_user) { FactoryGirl.create(:user, role: Role.find_by_name('super_admin')) }

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:super_admin_attributes) {
    FactoryGirl.attributes_for(:user, role_id: Role.find_by_name('super_admin').id)
  }

  let(:site_admin_attributes) {
    FactoryGirl.attributes_for(:user, role_id: Role.find_by_name('site_admin').id)
  }

  let(:valid_attributes) {
    FactoryGirl.attributes_for(:user, role_id: Role.find_by_name('user_manager').id)
  }

  let(:invalid_attributes) {
    FactoryGirl.attributes_for(:user, email: '', role_id: Role.find_by_name('user_manager').id)
  }


  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

    describe "GET index" do
      before(:example) {
        sign_in :user, user_manager_user
      }

      it "assigns all users as @users" do
        user = FactoryGirl.create(:user, valid_attributes)
        get :index, {}, valid_session
        expect(assigns(:users)).to eq([user_manager_user, user])
      end

      describe "GET show" do
        it "assigns the requested user as @user" do
          user = FactoryGirl.create(:user, valid_attributes)
          get :show, {:id => user.to_param}, valid_session
          expect(assigns(:user)).to eq(user)
        end
      end

      describe "GET new" do
        it "assigns a new user as @user" do
          get :new, {}, valid_session
          expect(assigns(:user)).to be_a_new(User)
        end
      end

      describe "GET edit" do
        it "assigns the requested user as @user" do
          user = FactoryGirl.create(:user, valid_attributes)
          get :edit, {:id => user.to_param}, valid_session
          expect(assigns(:user)).to eq(user)
        end
      end

      describe "POST create" do
        describe "with valid params" do
          it "creates a new User" do
            expect {
              post :create, {:user => valid_attributes}, valid_session
            }.to change(User, :count).by(1)
          end

          it "assigns a newly created user as @user" do
            post :create, {:user => valid_attributes}, valid_session
            expect(assigns(:user)).to be_a(User)
            expect(assigns(:user)).to be_persisted
          end

          it "redirects to the created user" do
            post :create, {:user => valid_attributes}, valid_session
            expect(response).to redirect_to(User.last)
          end
        end

        describe "with invalid params" do
          it "assigns a newly created but unsaved user as @user" do
            post :create, {:user => invalid_attributes}, valid_session
            expect(assigns(:user)).to be_a_new(User)
          end

          it "re-renders the 'new' template" do
            post :create, {:user => invalid_attributes}, valid_session
            expect(response).to render_template("new")
          end
        end
      end

      describe "PUT update" do
        describe "with valid params" do
          let(:new_attributes) {
            FactoryGirl.build(:user, email: 'new@email.com').attributes
          }

          it "updates the requested user" do
            user = FactoryGirl.create(:user, valid_attributes)
            put :update, {:id => user.to_param, :user => new_attributes}, valid_session
            user.reload
          end

          it "assigns the requested user as @user" do
            user = FactoryGirl.create(:user, valid_attributes)
            put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
            expect(assigns(:user)).to eq(user)
          end

          it "redirects to the user" do
            user = FactoryGirl.create(:user, valid_attributes)
            put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
            expect(response).to redirect_to(user)
          end

        end

        describe "with invalid params" do
          it "assigns the user as @user" do
            user = FactoryGirl.create(:user, valid_attributes)
            put :update, {:id => user.to_param, :user => invalid_attributes}, valid_session
            expect(assigns(:user)).to eq(user)
          end

          it "re-renders the 'edit' template" do
            user = FactoryGirl.create(:user, valid_attributes)
            put :update, {:id => user.to_param, :user => invalid_attributes}, valid_session
            expect(response).to render_template("edit")
          end
        end
      end

      describe "DELETE destroy" do
        it "destroys the requested user" do
          user = FactoryGirl.create(:user, valid_attributes)

          expect {
            delete :destroy, {:id => user.to_param}, valid_session
          }.to change(User, :count).by(-1)
        end

        it "redirects to the users list" do
          user = FactoryGirl.create(:user, valid_attributes)

          delete :destroy, {:id => user.to_param}, valid_session
          expect(response).to redirect_to(users_url)
        end
      end
    end

  describe "super admin" do
    before(:example) {
      sign_in :user, super_admin_user
    }

    it "successfully updates a user manager to super admin role" do
      user = FactoryGirl.create(:user, valid_attributes)
      put :update, {id: user.to_param, user: super_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(user)
      expect(user.role.name).to eq("super_admin")
    end

    it "successfully updates a user manager to site admin role" do
      user = FactoryGirl.create(:user, valid_attributes)
      put :update, {id: user.to_param, user: site_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(user)
      expect(user.role.name).to eq("site_admin")
    end

    it "successfully updates a site admin to super admin role" do
      user = FactoryGirl.create(:user, site_admin_attributes)
      put :update, {id: user.to_param, user: super_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(user)
      expect(user.role.name).to eq("super_admin")
    end
  end

  describe "site admin" do
    before(:example) {
      sign_in :user, site_admin_user
    }

    it "fails to update another site admin to super admin role" do
      user = FactoryGirl.create(:user, site_admin_attributes)
      put :update, {id: user.to_param, user: super_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform that action.")
      expect(user.role.name).to eq("site_admin")
    end

    it "fails to update a user manager to super admin role" do
      user = FactoryGirl.create(:user, valid_attributes)
      put :update, {id: user.to_param, user: super_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform that action.")
      expect(user.role.name).to eq("user_manager")
    end

    it "successfully updates a user manager to site admin role" do
      user = FactoryGirl.create(:user, valid_attributes)
      put :update, {id: user.to_param, user: site_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(user)
      expect(user.role.name).to eq("site_admin")
    end
  end

  describe "user manager" do
    before(:example) {
      sign_in :user, user_manager_user
    }

    it "fails to update another user manager to super_admin role" do
      user = FactoryGirl.create(:user, valid_attributes)
      put :update, {id: user.to_param, user: super_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform that action.")
      expect(user.role.name).to eq("user_manager")
    end

    it "fails to update another user manager to site_admin role" do
      user = FactoryGirl.create(:user, valid_attributes)
      put :update, {id: user.to_param, user: site_admin_attributes}, valid_session
      user.reload
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform that action.")
      expect(user.role.name).to eq("user_manager")
    end
  end
end
