require 'test_helper'

class ApiTokensControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:john) # role: admin
    @editor = users(:bob) # role: editor
  end

  test "admin can view the index" do
    sign_in(@admin)
    get api_tokens_url
    assert_response :success
  end

  test "index lists the current user's tokens" do
    sign_in(@admin)
    @admin.generate_api_token('Existing Token')

    get api_tokens_url
    assert_response :success
    assert_match 'Existing Token', @response.body
  end

  test "create generates a new token and redirects with a notice" do
    sign_in(@admin)

    assert_difference('@admin.api_tokens.count', 1) do
      post api_tokens_url, params: { name: 'My New Token' }
    end

    assert_redirected_to api_tokens_path
    assert_equal 'API token generated successfully', flash[:notice]
    assert_equal 'My New Token', @admin.api_tokens.order(:created_at).last.name
  end

  test "create without a name defaults to 'Default API Key'" do
    sign_in(@admin)

    post api_tokens_url, params: { name: '' }

    assert_redirected_to api_tokens_path
    assert_equal 'Default API Key', @admin.api_tokens.order(:created_at).last.name
  end

  test "newly generated plain-text token is displayed once on the index page" do
    sign_in(@admin)

    post api_tokens_url, params: { name: 'Shown Once' }
    follow_redirect!

    assert_response :success
    assert_match 'Your new API token', @response.body
  end

  test "destroy removes the token and redirects with a notice" do
    sign_in(@admin)
    token, _plain = @admin.generate_api_token('To Delete')

    assert_difference('@admin.api_tokens.count', -1) do
      delete api_token_url(token)
    end

    assert_redirected_to api_tokens_path
    assert_equal 'API token deleted successfully', flash[:notice]
  end

  test "destroy only allows deleting the current user's own tokens" do
    sign_in(@admin)
    other_token, _plain = @editor.generate_api_token('Someone Elses Token')

    delete api_token_url(other_token)
    assert_response :not_found
    assert ApiToken.exists?(other_token.id)
  end

  test "non-admin users are denied access to the index" do
    sign_in(@editor)
    assert_raises(RuntimeError, 'Only Admin allowed access') do
      get api_tokens_url
    end
  end

  test "unauthenticated users are redirected to sign in" do
    get api_tokens_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
end
