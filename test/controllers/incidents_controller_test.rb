require 'test_helper'

class IncidentsControllerTest < ActionController::TestCase
  setup do
    @incident = incidents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:incidents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create incident" do
    assert_difference('Incident.count') do
      post :create, incident: { date_of_arrest: @incident.date_of_arrest, date_of_release: @incident.date_of_release, description_of_arrest: @incident.description_of_arrest, description_of_release: @incident.description_of_release, prison_id: @incident.prison_id, prisoner_id: @incident.prisoner_id, subtype_id: @incident.subtype_id, type_id: @incident.type_id }
    end

    assert_redirected_to incident_path(assigns(:incident))
  end

  test "should show incident" do
    get :show, id: @incident
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @incident
    assert_response :success
  end

  test "should update incident" do
    patch :update, id: @incident, incident: { date_of_arrest: @incident.date_of_arrest, date_of_release: @incident.date_of_release, description_of_arrest: @incident.description_of_arrest, description_of_release: @incident.description_of_release, prison_id: @incident.prison_id, prisoner_id: @incident.prisoner_id, subtype_id: @incident.subtype_id, type_id: @incident.type_id }
    assert_redirected_to incident_path(assigns(:incident))
  end

  test "should destroy incident" do
    assert_difference('Incident.count', -1) do
      delete :destroy, id: @incident
    end

    assert_redirected_to incidents_path
  end
end
