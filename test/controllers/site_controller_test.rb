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
    put update_user_role_url, params: { user: {id: @user2.id, role: 'admin' }}
    assert_not_equal old_role, @user2.reload.role
  end

  test "AdminでなくてはSite Settingのページにアクセスできない" do
    @user2 = users( :bob )
    sign_in(@user2)
    assert_raises do
      get site_settings_url
    end
  end

  test "shoud get export and download" do
    get site_export_url
    assert_equal 'export.zip', response.header["Content-Disposition"].match("filename=\"(.*.zip)\"")[1]
  end
end
