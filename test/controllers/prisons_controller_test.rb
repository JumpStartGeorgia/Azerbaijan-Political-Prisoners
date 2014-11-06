require 'test_helper'

class PrisonsControllerTest < ActionController::TestCase
  setup do
    @prison = prisons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prisons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prison" do
    assert_difference('Prison.count') do
      post :create, prison: { name: @prison.name }
    end

    assert_redirected_to prison_path(assigns(:prison))
  end

  test "should show prison" do
    get :show, id: @prison
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @prison
    assert_response :success
  end

  test "should update prison" do
    patch :update, id: @prison, prison: { name: @prison.name }
    assert_redirected_to prison_path(assigns(:prison))
  end

  test "should destroy prison" do
    assert_difference('Prison.count', -1) do
      delete :destroy, id: @prison
    end

    assert_redirected_to prisons_path
  end
end
