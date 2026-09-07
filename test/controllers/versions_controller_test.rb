require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    @word = words(:one)
    get word_versions_url(@word)
    assert_response :redirect
  end

  test "should get show for the current version" do
    @word = words(:one)
    get word_version_url(@word, 0)
    assert_response :success
  end

  test "unknown word in versions returns 404" do
    get word_version_url("does-not-exist", 0)
    assert_response :not_found
  end

end
