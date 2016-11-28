require 'test_helper'

class WordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users( :john ) 
    sign_in(@user)

    @word = words(:one)
  end

  test "should get index" do
    get words_index_url
    assert_response :success
  end

  test "should get new" do
    get new_word_url
    assert_response :success
  end

  test "should create word" do
    assert_difference('Word.count') do
      post words_url, params: { word: { body: @word.body, title: @word.title + "_different_title" } }
    end

    assert_redirected_to word_url(Word.last)
  end

  test "User should added to the fav" do
    post words_url, params: { word: { body: '', title: 'fav-test' } }
    @word = Word.find_by_title('fav-test')
    assert_equal 1, @word.favorites.count
  end

  test "should show word" do
    get word_url(@word)
    assert_response :success
  end

  test "should get edit" do
    get edit_word_url(@word)
    assert_response :success
  end

  test "should update word" do
    patch word_url(@word), params: { word: { body: @word.body, title: @word.title } }
    assert_redirected_to word_url(@word)
  end

  test "should destroy word" do
    assert_difference('Word.count', -1) do
      delete word_url(@word)
    end

    assert_redirected_to words_url
  end
end
