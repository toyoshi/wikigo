require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:john)
    sign_in(@user)

    @attachment = attachments(:one)
    @attachment.user_id = @user.id
    @attachment.save
  end

  test "should get new" do
    get new_attachment_url
    assert_response :success
  end
end
