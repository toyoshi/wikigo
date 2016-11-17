require 'test_helper'

class WordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "format to middleman" do
    @word = words(:one)
    txt = @word.to_middleman
    assert_equal txt, <<"EOS"
---
title: MyString
date: 2016/01/01 10:00
tags: Very good, Bad
wiki:word_id: #{@word.id}
---

MyText
EOS
  end
end
