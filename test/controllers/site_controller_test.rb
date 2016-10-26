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

  test "update user role" do
    @user2 = users( :bob )
    old_role = @user2.role
    put update_user_role_url, user: {id: @user2.id, role: 'admin' }
    assert_not_equal old_role, @user2.reload.role
  end

end
