require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
  end

  test "new renders" do
    get new_password_path
    assert_response :success
  end

  test "create emails reset instructions for a known account" do
    assert_difference("ActionMailer::Base.deliveries.count", 1) do
      # deliver_later enqueues; the suite's :test adapter needs an explicit
      # drain (perform_enqueued_jobs from ActiveJob::TestHelper).
      perform_enqueued_jobs do
        post passwords_path, params: { email: @user.email }
      end
    end
    assert_redirected_to new_user_session_path

    mail = ActionMailer::Base.deliveries.last
    # multipart html+text: read the text part, body itself stays empty.
    assert_match %r{/passwords/\S+/edit}, mail.text_part.body.to_s
  end

  test "create stays silent about unknown accounts" do
    assert_no_difference("ActionMailer::Base.deliveries.count") do
      perform_enqueued_jobs do
        post passwords_path, params: { email: "missing-user@example.com" }
      end
    end
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_select "body", text: /if an account/
  end

  test "update sets the new password and clears sessions" do
    @user.sessions.create!
    token = @user.password_reset_token

    put password_path(token), params: { password: "newpassword", password_confirmation: "newpassword" }
    assert_redirected_to new_user_session_path

    assert_equal 0, @user.sessions.count
    assert @user.reload.authenticate_password("newpassword")
  end

  test "update with mismatched confirmation bounces back" do
    token = @user.password_reset_token

    put password_path(token), params: { password: "newpassword", password_confirmation: "other" }
    assert_redirected_to edit_password_path(token)
  end
end
