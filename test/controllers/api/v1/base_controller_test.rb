require 'test_helper'

# Api::V1::BaseController is abstract (ActionController::API, no routes of its
# own), so its Bearer token authentication is exercised through a concrete
# subclass's routes (Api::V1::WordsController).
class Api::V1::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
    @token, @plain_token = @user.generate_api_token('Auth Test Token')
  end

  def json
    JSON.parse(@response.body)
  end

  test "valid bearer token authenticates and grants access" do
    get api_v1_words_url, headers: { 'Authorization' => "Bearer #{@plain_token}" }
    assert_response :success
  end

  test "valid bearer token updates last_used_at on the token" do
    assert_nil @token.last_used_at

    get api_v1_words_url, headers: { 'Authorization' => "Bearer #{@plain_token}" }
    assert_response :success

    assert_not_nil @token.reload.last_used_at
  end

  test "valid bearer token sets current_user to the token owner" do
    post api_v1_words_url,
      params: { word: { title: 'Owned By Token User' } },
      headers: { 'Authorization' => "Bearer #{@plain_token}" },
      as: :json

    assert_response :created
    word = Word.find_by(title: 'Owned By Token User')
    assert_equal [@user], word.favorites.map(&:user)
  end

  test "missing Authorization header returns 401 with documented JSON error shape" do
    get api_v1_words_url
    assert_response :unauthorized
    assert_equal 'application/json', @response.media_type
    assert_equal({
      'error' => 'Unauthorized',
      'message' => 'Invalid or missing API token'
    }, json)
  end

  test "invalid/unknown token returns 401 with JSON error" do
    get api_v1_words_url, headers: { 'Authorization' => 'Bearer this-token-does-not-exist' }
    assert_response :unauthorized
    assert_equal 'Unauthorized', json['error']
  end

  test "malformed Authorization header (wrong scheme) returns 401" do
    get api_v1_words_url, headers: { 'Authorization' => 'Basic dXNlcjpwYXNz' }
    assert_response :unauthorized
    assert_equal 'Unauthorized', json['error']
  end

  test "blank token value returns 401" do
    get api_v1_words_url, headers: { 'Authorization' => 'Bearer ' }
    assert_response :unauthorized
  end

  test "token belonging to a deleted ApiToken record no longer authenticates" do
    plain = @plain_token
    @token.destroy
    get api_v1_words_url, headers: { 'Authorization' => "Bearer #{plain}" }
    assert_response :unauthorized
  end

  test "a valid token belonging to a different user also authenticates successfully" do
    other_user = users(:bob)
    _other_token, other_plain = other_user.generate_api_token('Bob Token')

    get api_v1_words_url, headers: { 'Authorization' => "Bearer #{other_plain}" }
    assert_response :success
  end

  test "ApiToken#expired? is always false (no expiration currently supported)" do
    assert_equal false, @token.expired?
  end

  test "authenticate_api_user denies access when ApiToken#expired? returns true" do
    # No token currently expires (ApiToken#expired? is hardcoded to false), but
    # the authenticate_api_user before_action already checks it. This documents
    # the intended behavior for when expiration support is added, by forcing
    # #expired? to true for the duration of the request and confirming the
    # before_action still rejects the request.
    token = @token
    singleton = class << token; self; end
    singleton.send(:define_method, :expired?) { true }

    original_find_by_token = ApiToken.method(:find_by_token)
    ApiToken.define_singleton_method(:find_by_token) { |*_args| token }

    get api_v1_words_url, headers: { 'Authorization' => "Bearer #{@plain_token}" }
    assert_response :unauthorized
  ensure
    ApiToken.define_singleton_method(:find_by_token, original_find_by_token)
  end
end
