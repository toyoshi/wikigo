require 'test_helper'

class WordsResultTest < ActiveSupport::TestCase
  test "exposes the success flag and word passed to .new" do
    word = Word.first
    result = Words::Result.new(true, word)

    assert_equal true, result.success?
    assert_same word, result.word
  end

  test "reflects a falsy success flag" do
    word = Word.new(title: 'not saved')
    result = Words::Result.new(false, word)

    assert_equal false, result.success?
    assert_same word, result.word
  end

  test "supports positional access like a Struct" do
    word = Word.first
    result = Words::Result.new(true, word)

    assert_equal true, result[0]
    assert_same word, result[1]
    assert_equal [true, word], result.to_a
  end
end
