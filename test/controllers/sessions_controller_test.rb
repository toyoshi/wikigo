require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
  end

  test "new renders the sign in form" do
    get new_user_session_path
    assert_response :success
    assert_select 'form[action=?]', "/signin"
  end

  test "create signs in with username and password" do
    post signin_path, params: { login: @user.username, password: "password" }
    assert_redirected_to root_path

    # The Session record is the proof: server-side state, not just a cookie.
    assert_equal 1, @user.sessions.count
  end

  test "create signs in with email and password" do
    post signin_path, params: { login: @user.email, password: "password" }
    assert_redirected_to root_path
  end

  test "create rejects a wrong password" do
    post signin_path, params: { login: @user.username, password: "wrong" }
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_select "body", text: /Try another/
    assert_equal 0, Session.count
  end

  test "destroy terminates the session" do
    sign_in @user
    delete destroy_user_session_path
    assert_redirected_to new_user_session_path
    assert_equal 0, @user.sessions.count
  end
end
