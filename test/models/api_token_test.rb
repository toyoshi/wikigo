require 'test_helper'

class ApiTokenTest < ActiveSupport::TestCase
  # --- validations ---

  test "invalid without a name" do
    token = ApiToken.new(user: users(:john), name: nil, token_digest: "digest123")
    assert_not token.valid?
    assert_includes token.errors[:name], "can't be blank"
  end

  test "invalid without a user" do
    token = ApiToken.new(user: nil, name: "Key", token_digest: "digest123")
    assert_not token.valid?
    assert_includes token.errors[:user], "must exist"
  end

  test "invalid without a token_digest" do
    token = ApiToken.new(user: users(:john), name: "Key", token_digest: nil)
    assert_not token.valid?
    assert_includes token.errors[:token_digest], "can't be blank"
  end

  test "invalid with a duplicate name for the same user" do
    ApiToken.create!(user: users(:john), name: "Key", token_digest: "digest-a")
    duplicate = ApiToken.new(user: users(:john), name: "Key", token_digest: "digest-b")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "allows the same name for different users" do
    ApiToken.create!(user: users(:john), name: "Key", token_digest: "digest-a")
    other = ApiToken.new(user: users(:bob), name: "Key", token_digest: "digest-b")
    assert other.valid?
  end

  test "invalid with a duplicate token_digest across users" do
    ApiToken.create!(user: users(:john), name: "Key A", token_digest: "same-digest")
    duplicate = ApiToken.new(user: users(:bob), name: "Key B", token_digest: "same-digest")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:token_digest], "has already been taken"
  end

  # --- token generation / lookup ---

  test "create_for_user generates a persisted token and returns the plain token" do
    token, plain_token = ApiToken.create_for_user(users(:john), "My Key")

    assert token.persisted?
    assert_equal "My Key", token.name
    assert_equal users(:john), token.user
    assert_equal 64, plain_token.length # SecureRandom.hex(32) => 64 hex chars
    assert_equal Digest::SHA256.hexdigest(plain_token), token.token_digest
  end

  test "find_by_token returns the token matching the plain token's digest" do
    token, plain_token = ApiToken.create_for_user(users(:john), "My Key")
    assert_equal token, ApiToken.find_by_token(plain_token)
  end

  test "find_by_token returns nil for an unknown plain token" do
    assert_nil ApiToken.find_by_token("not-a-real-token")
  end

  test "find_by_token returns nil for a blank token" do
    assert_nil ApiToken.find_by_token(nil)
    assert_nil ApiToken.find_by_token("")
  end

  # --- last_used_at / expiry ---

  test "touch_last_used! updates last_used_at" do
    token, = ApiToken.create_for_user(users(:john), "My Key")
    assert_nil token.last_used_at

    token.touch_last_used!

    assert_not_nil token.reload.last_used_at
  end

  test "expired? is always false" do
    token, = ApiToken.create_for_user(users(:john), "My Key")
    assert_equal false, token.expired?
  end
end
