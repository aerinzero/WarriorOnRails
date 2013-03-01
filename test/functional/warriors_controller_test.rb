require 'test_helper'

class WarriorsControllerTest < ActionController::TestCase
  setup do
    @warrior = warriors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:warriors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create warrior" do
    assert_difference('Warrior.count') do
      post :create, warrior: { code: @warrior.code, level: @warrior.level, name: @warrior.name }
    end

    assert_redirected_to warrior_path(assigns(:warrior))
  end

  test "should show warrior" do
    get :show, id: @warrior
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @warrior
    assert_response :success
  end

  test "should update warrior" do
    put :update, id: @warrior, warrior: { code: @warrior.code, level: @warrior.level, name: @warrior.name }
    assert_redirected_to warrior_path(assigns(:warrior))
  end

  test "should destroy warrior" do
    assert_difference('Warrior.count', -1) do
      delete :destroy, id: @warrior
    end

    assert_redirected_to warriors_path
  end
end
