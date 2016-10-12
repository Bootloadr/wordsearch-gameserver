require 'test_helper'

class AdminpControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get adminp_create_url
    assert_response :success
  end

end
