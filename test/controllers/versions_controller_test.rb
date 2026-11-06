require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @word = words(:one)
  end

  test "should get index" do
    get word_versions_url(@word)
    assert_response :redirect
  end

  test "should get show for the current version" do
    get word_version_url(@word, 0)
    assert_response :success
  end

  test "unknown word in versions returns 404" do
    get word_version_url("does-not-exist", 0)
    assert_response :not_found
  end

  test "version page renders the body stored with that version, not the latest (#82)" do
    @word.update!(body: "first version body")
    @word.update!(body: "latest version body")

    version = version_carrying("first version body")

    get word_version_url(@word, version)
    assert_response :success
    assert_match "first version body", response.body
    assert_not_includes response.body, "latest version body"
  end

  test "rollback restores the selected version including its body (#82)" do
    sign_in(users(:john))
    original_title = @word.title
    @word.update!(body: "original body")
    @word.update!(title: "#{original_title} renamed", body: "changed body")

    version = version_carrying("original body")
    assert_equal original_title, version.reify.title

    assert_no_difference "Word.count" do
      patch rollback_word_version_url(@word, version)
    end
    # The redirect target reflects the restored title, which changed during
    # the rollback itself, so assert on the redirect rather than a fixed path.
    assert_response :redirect

    @word.reload
    assert_equal "original body", @word.body.to_plain_text
    assert_equal original_title, @word.title
  end

  private

  # Finds the PaperTrail version whose captured snapshot contains the text.
  def version_carrying(text)
    version = @word.versions.to_a.find { |v| v.reify.body_plain_text.to_s.include?(text) }
    assert_not_nil version, "expected a version carrying #{text.inspect}"
    version
  end
end
