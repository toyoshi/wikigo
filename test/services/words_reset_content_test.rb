require 'test_helper'

class WordsResetContentTest < ActiveSupport::TestCase
  test "deletes all tags and every word except the protected pages, resetting them" do
    Word.delete_all

    main_page = Word.create!(title: 'Main Page', body: 'old main', tag_list: 'keep')
    side_bar = Word.create!(title: 'Side Bar', body: 'old side', tag_list: 'keep')
    Word.create!(title: 'Disposable One', tag_list: 'foo')
    Word.create!(title: 'Disposable Two', tag_list: 'bar')

    result = Words::ResetContent.new.call

    assert_equal 2, result.deleted_count
    assert result.tags_count >= 3

    assert_equal 0, ActsAsTaggableOn::Tag.count
    assert_equal ['Main Page', 'Side Bar'], Word.order(:title).pluck(:title)

    assert_equal 'Wiki wiki go!', main_page.reload.body.to_plain_text
    assert_empty main_page.tag_list
    assert_equal '--- menu ---', side_bar.reload.body.to_plain_text
    assert_empty side_bar.tag_list
  end
end
