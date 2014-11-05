require 'test_helper'

class PrisonersControllerTest < ActionController::TestCase
  setup do
    @prisoner = prisoners(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prisoners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prisoner" do
    assert_difference('Prisoner.count') do
      post :create, prisoner: { name: @prisoner.name }
    end

    assert_redirected_to prisoner_path(assigns(:prisoner))
  end

  test "should show prisoner" do
    get :show, id: @prisoner
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @prisoner
    assert_response :success
  end

  test "should update prisoner" do
    patch :update, id: @prisoner, prisoner: { name: @prisoner.name }
    assert_redirected_to prisoner_path(assigns(:prisoner))
  end

  test "should destroy prisoner" do
    assert_difference('Prisoner.count', -1) do
      delete :destroy, id: @prisoner
    end

    assert_redirected_to prisoners_path
  end
end
