require 'test_helper'

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.user_registration_token = 'test-invite-token'
  end

  test "sign up form renders with a valid invitation token" do
    get new_user_registration_url(rt: 'test-invite-token')

    assert_response :success
    assert_includes response.body, 'Sign up'
  end

  test "sign up is blocked without a valid token when users exist" do
    get new_user_registration_url

    assert_redirected_to root_url
    follow_redirect!
    assert_match 'invitation', response.body
  end

  test "first user can sign up without a token" do
    User.delete_all

    get new_user_registration_url
    assert_response :success
  end

  test "registration with a valid invitation token creates a user" do
    get new_user_registration_url(rt: 'test-invite-token')
    assert_response :success

    assert_difference('User.count') do
      post user_registration_url, params: {
        user: {
          username: 'newbie',
          email: 'newbie@example.com',
          password: 'super-secret-1',
          password_confirmation: 'super-secret-1'
        }
      }
    end

    assert User.find_by(username: 'newbie').present?
  end
end
