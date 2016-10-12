require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get join" do
    get welcome_join_url
    assert_response :success
  end

  test "should get create" do
    get welcome_create_url
    assert_response :success
  end

end
