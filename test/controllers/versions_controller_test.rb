require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    @word = words(:one)
    get word_versions_url(@word)
    assert_response :redirect
  end

end
