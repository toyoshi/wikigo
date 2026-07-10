require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  test "loads fixtures as valid records" do
    assert attachments(:one).valid?
    assert attachments(:two).valid?
  end

  test "invalid without a user" do
    attachment = Attachment.new(user: nil, file: "photo.png")
    assert_not attachment.valid?
    assert_includes attachment.errors[:user], "must exist"
  end

  test "belongs to a user" do
    attachment = attachments(:one)
    assert_equal users(:john), attachment.user
  end

  test "destroying the owning user does not raise (no dependent restriction defined)" do
    user = User.create!(username: "attachowner", email: "attachowner@example.com", password: "password123")
    Attachment.create!(user: user, file: "orphan.png")

    assert_nothing_raised { user.destroy }
  end
end
