require 'test_helper'

class PnewpControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pnewp_index_url
    assert_response :success
  end

end
