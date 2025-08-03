require 'test_helper'

class WordsHelperTest < ActiveSupport::TestCase
  include WordsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers
  
  def default_url_options
    { host: 'localhost', port: 3000 }
  end
  
  def setup
    # Create test words with different lengths (using ActionText)
    @short_word = Word.create!(title: "張飛")
    @short_word.body = "短い"
    @short_word.save!
    
    @long_word = Word.create!(title: "張飛卒")
    @long_word.body = "長い"
    @long_word.save!
    
    @longest_word = Word.create!(title: "馬超と張飛")
    @longest_word.body = "一番長い"
    @longest_word.save!
  end

  def teardown
    Word.destroy_all
  end

  test "should link longer words first" do
    content = "張飛卒は勇敢だった"
    result = add_word_links_to_content(content, nil)
    
    # 張飛卒 should be linked, not 張飛
    assert_includes result, "張飛卒</a>"
    refute_includes result, ">張飛</a>卒"
  end

  test "should link separate instances of different words" do
    content = "張飛卒と張飛は違う"
    result = add_word_links_to_content(content, nil)
    
    # Both should be linked but separately
    assert_includes result, "張飛卒</a>"
    assert_includes result, ">張飛</a>は"
  end

  test "should not create nested links" do
    content = "張飛卒は強い"
    result = add_word_links_to_content(content, nil)
    
    # Should not have nested <a> tags
    refute_includes result, "<a><a"
    refute_includes result, "</a></a>"
  end

  test "should handle empty content" do
    result = add_word_links_to_content("", nil)
    assert_equal "", result
    
    result = add_word_links_to_content(nil, nil)
    assert_nil result
  end

  test "should exclude specified word" do
    content = "張飛卒は勇敢だった"
    result = add_word_links_to_content(content, "張飛卒")
    
    # 張飛卒 should not be linked when excluded
    refute_includes result, ">張飛卒</a>"
  end

  test "should work with ActionText content" do
    # Simulate ActionText HTML structure
    content = '<div class="trix-content">張飛卒は勇敢だった</div>'
    result = add_word_links_to_content(content, nil)
    
    # Should link inside the div
    assert_includes result, "張飛卒</a>"
  end
end