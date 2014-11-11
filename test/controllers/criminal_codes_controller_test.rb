require 'test_helper'

class CriminalCodesControllerTest < ActionController::TestCase
  setup do
    @criminal_code = criminal_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:criminal_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create criminal_code" do
    assert_difference('CriminalCode.count') do
      post :create, criminal_code: { name: @criminal_code.name }
    end

    assert_redirected_to criminal_code_path(assigns(:criminal_code))
  end

  test "should show criminal_code" do
    get :show, id: @criminal_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @criminal_code
    assert_response :success
  end

  test "should update criminal_code" do
    patch :update, id: @criminal_code, criminal_code: { name: @criminal_code.name }
    assert_redirected_to criminal_code_path(assigns(:criminal_code))
  end

  test "should destroy criminal_code" do
    assert_difference('CriminalCode.count', -1) do
      delete :destroy, id: @criminal_code
    end

    assert_redirected_to criminal_codes_path
  end
end
