require 'test_helper'

class SiteControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users( :john ) 
    sign_in(@user)
  end

  test "should get members" do
    get site_members_url
    assert_response :success
  end

end
