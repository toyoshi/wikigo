require 'test_helper'

class WordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users( :john ) 
    sign_in(@user)

    @word = words(:one)
  end

  test "an expired server-side session no longer authenticates (#138)" do
    sign_in(@user)
    Current.session.update!(expires_at: 1.minute.ago)

    post words_url, params: { word: { title: 'Expired Session Word' } }

    assert_redirected_to new_user_session_path
    assert_nil Word.find_by(title: 'Expired Session Word')
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

  test "should show word as json" do
    get word_url(@word), headers: { "Accept" => "application/json" }
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.media_type + "; charset=" + response.charset
    assert_equal @word.title, JSON.parse(response.body)["title"]
  end

  test "should show word as markdown" do
    get word_url(@word), headers: { "Accept" => "text/markdown" }
    assert_response :success
    assert_equal "# #{@word.title}\n\n", response.body.lines.first + "\n"
  end

  test "should get edit" do
    get edit_word_url(@word)
    assert_response :success
  end

  test "should update word" do
    patch word_url(@word), params: { word: { body: @word.body, title: @word.title } }
    assert_redirected_to word_url(@word)
  end

  test "unknown word title returns 404 instead of 500" do
    get word_url("definitely-not-a-word")
    assert_response :not_found
  end

  test "should destroy word" do
    assert_difference('Word.count', -1) do
      delete word_url(@word)
    end

    assert_redirected_to words_url
  end
end
