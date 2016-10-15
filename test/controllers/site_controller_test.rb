require 'test_helper'

class SiteControllerTest < ActionDispatch::IntegrationTest
  test "should get members" do
    get site_members_url
    assert_response :success
  end

end
