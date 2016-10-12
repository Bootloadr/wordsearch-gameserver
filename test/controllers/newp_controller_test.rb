require 'test_helper'

class NewpControllerTest < ActionDispatch::IntegrationTest
  test "should get join" do
    get newp_join_url
    assert_response :success
  end

end
