require 'test_helper'

class ProfitControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get obsolete" do
    get :obsolete
    assert_response :success
  end

  test "should get scan" do
    get :scan
    assert_response :success
  end

end
