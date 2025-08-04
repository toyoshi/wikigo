require 'test_helper'

class WordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "format to middleman" do
    @word = words(:one)
    txt = @word.to_middleman
    expected = <<"EOS"
---
title: MyString
date: #{@word.created_at}
tags: Very good, Bad
wiki:word_id: #{@word.id}
---

#{@word.body.to_s}
EOS
    assert_equal expected, txt
  end
end
