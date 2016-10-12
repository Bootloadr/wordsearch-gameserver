require 'test_helper'

class PadminpControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get padminp_index_url
    assert_response :success
  end

end
