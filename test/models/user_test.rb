require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def valid_attributes(overrides = {})
    {
      username: "newuser",
      email: "newuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    }.merge(overrides)
  end

  # --- validations ---

  test "valid with proper attributes" do
    user = User.new(valid_attributes)
    assert user.valid?
  end

  test "invalid without a username" do
    user = User.new(valid_attributes(username: nil))
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "invalid with a username shorter than 3 characters" do
    user = User.new(valid_attributes(username: "jo"))
    assert_not user.valid?
    assert_includes user.errors[:username], "is too short (minimum is 3 characters)"
  end

  test "invalid with a duplicate username regardless of case" do
    user = User.new(valid_attributes(username: "JOHN", email: "different@example.com"))
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "invalid with a username containing disallowed characters" do
    user = User.new(valid_attributes(username: "bad name!"))
    assert_not user.valid?
    assert_includes user.errors[:username], "is invalid"
  end

  test "invalid with a username that smuggles invalid characters after a newline" do
    # Regression test: the format validation used to anchor with ^ / $, which
    # in Ruby match line boundaries rather than string boundaries, so a
    # username like "good\nbad!!!" would incorrectly pass validation.
    user = User.new(valid_attributes(username: "good\nbad!!!"))
    assert_not user.valid?
    assert_includes user.errors[:username], "is invalid"
  end

  test "valid with a username containing letters, numbers, underscore and dot" do
    user = User.new(valid_attributes(username: "user_name.99"))
    assert user.valid?
  end

  test "invalid without a valid email" do
    user = User.new(valid_attributes(email: "not-an-email"))
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "invalid with a duplicate email" do
    user = User.new(valid_attributes(email: users(:john).email, username: "uniqueusername"))
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  # --- role enum ---

  test "defaults to editor role for a plain new user" do
    user = User.create!(valid_attributes)
    assert user.editor?
  end

  test "role can be set to admin" do
    user = User.create!(valid_attributes(role: :admin))
    assert user.admin?
  end

  # --- keep_admin_exist ---

  test "keeps at least one admin by re-promoting the sole admin who is demoted" do
    john = users(:john)
    assert john.admin?
    assert_equal 1, User.admin.count

    john.update!(role: :editor)

    assert john.reload.admin?
  end

  test "allows demoting an admin when another admin still exists" do
    john = users(:john)
    other_admin = User.create!(valid_attributes(username: "secondadmin", email: "second@example.com", role: :admin))
    assert_equal 2, User.admin.count

    john.update!(role: :editor)

    assert john.reload.editor?
    assert other_admin.reload.admin?
  end

  # --- find_for_database_authentication ---

  test "finds a user by username via the login virtual attribute" do
    found = User.find_for_database_authentication(login: "JOHN")
    assert_equal users(:john), found
  end

  test "finds a user by email via the login virtual attribute" do
    found = User.find_for_database_authentication(login: users(:john).email.upcase)
    assert_equal users(:john), found
  end

  test "finds a user by username or email attribute directly" do
    found = User.find_for_database_authentication(username: "bob")
    assert_equal users(:bob), found
  end

  test "returns nil when no login attribute matches" do
    assert_nil User.find_for_database_authentication(login: "nobody-here")
  end

  test "returns nil when neither login, username nor email is supplied" do
    assert_nil User.find_for_database_authentication(role: "admin")
  end

  # --- API token helpers ---

  test "generate_api_token creates a token for the user" do
    user = users(:bob)
    token, plain_token = user.generate_api_token("My Key")

    assert token.persisted?
    assert_equal "My Key", token.name
    assert_equal user, token.user
    assert_equal ApiToken.find_by_token(plain_token), token
  end

  test "generate_api_token replaces an existing token with the same name" do
    user = users(:bob)
    first_token, = user.generate_api_token("My Key")
    second_token, = user.generate_api_token("My Key")

    assert_not ApiToken.exists?(first_token.id)
    assert ApiToken.exists?(second_token.id)
  end

  test "generate_api_token called twice with the default name keeps a single default token" do
    user = users(:bob)
    first_token, = user.generate_api_token
    second_token, = user.generate_api_token

    # The second call destroys the exact "Default API Key" match before
    # checking for name collisions, so the LIKE-based disambiguation never
    # actually triggers for this call pattern; the name stays "Default API Key".
    assert_equal "Default API Key", first_token.name
    assert_equal "Default API Key", second_token.name
    assert_equal 1, user.api_tokens.where("name LIKE ?", "Default API Key%").count
  end

  test "current_api_token returns the first token for the user" do
    user = users(:bob)
    assert_nil user.current_api_token
    token, = user.generate_api_token
    assert_equal token, user.current_api_token
  end
end
