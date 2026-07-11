require 'test_helper'

class Api::V1::WordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
    _token, @plain_token = @user.generate_api_token('Test Token')
    @word = words(:one)
  end

  def auth_headers(token = @plain_token)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json
    JSON.parse(@response.body)
  end

  # -- index -----------------------------------------------------------

  test "index returns words with pagination metadata" do
    get api_v1_words_url, headers: auth_headers
    assert_response :success

    body = json
    assert body.key?('words')
    assert body.key?('pagination')

    pagination = body['pagination']
    assert_equal 1, pagination['current_page']
    assert pagination.key?('total_pages')
    assert pagination.key?('total_count')
    assert_equal 25, pagination['per_page']
  end

  test "index word entries expose expected fields and exclude body" do
    get api_v1_words_url, headers: auth_headers
    assert_response :success

    word_json = json['words'].find { |w| w['id'] == @word.id }
    assert_not_nil word_json
    assert_equal @word.title, word_json['title']
    assert_equal @word.to_param, word_json['slug']
    assert_equal "/#{@word.to_param}", word_json['url']
    assert_kind_of Array, word_json['tags']
    assert_not_nil word_json['created_at']
    assert_not_nil word_json['updated_at']
    assert_not word_json.key?('body')
    assert_not word_json.key?('body_html')
  end

  test "index respects per_page and caps it at 100" do
    28.times { |i| Word.create!(title: "Bulk Word #{i}") }

    get api_v1_words_url, params: { per_page: 5 }, headers: auth_headers
    assert_response :success
    assert_equal 5, json['words'].size
    assert_equal 5, json['pagination']['per_page']

    get api_v1_words_url, params: { per_page: 1000 }, headers: auth_headers
    assert_response :success
    assert_equal 100, json['pagination']['per_page']
  end

  test "index supports page parameter" do
    28.times { |i| Word.create!(title: "Bulk Word #{i}") }

    get api_v1_words_url, params: { page: 2, per_page: 10 }, headers: auth_headers
    assert_response :success
    assert_equal 2, json['pagination']['current_page']
  end

  test "index sorts by title ascending" do
    Word.delete_all
    Word.create!(title: "Zeta")
    Word.create!(title: "Alpha")
    Word.create!(title: "Mid")

    get api_v1_words_url, params: { sort: 'title_asc' }, headers: auth_headers
    assert_response :success
    titles = json['words'].map { |w| w['title'] }
    assert_equal %w[Alpha Mid Zeta], titles
  end

  test "index sorts by title descending" do
    Word.delete_all
    Word.create!(title: "Zeta")
    Word.create!(title: "Alpha")
    Word.create!(title: "Mid")

    get api_v1_words_url, params: { sort: 'title_desc' }, headers: auth_headers
    assert_response :success
    titles = json['words'].map { |w| w['title'] }
    assert_equal %w[Zeta Mid Alpha], titles
  end

  test "index defaults to updated_at descending when sort is missing" do
    Word.delete_all
    older = Word.create!(title: "Older")
    older.update_column(:updated_at, 2.days.ago)
    newer = Word.create!(title: "Newer")
    newer.update_column(:updated_at, 1.minute.ago)

    get api_v1_words_url, headers: auth_headers
    assert_response :success
    titles = json['words'].map { |w| w['title'] }
    assert_equal ['Newer', 'Older'], titles
  end

  test "index filters by title using ransack q[title_cont]" do
    Word.delete_all
    Word.create!(title: "Findable Widget")
    Word.create!(title: "Unrelated")

    get api_v1_words_url, params: { q: { title_cont: 'Findable' } }, headers: auth_headers
    assert_response :success
    titles = json['words'].map { |w| w['title'] }
    assert_equal ['Findable Widget'], titles
  end

  # -- show --------------------------------------------------------------

  test "show returns word by numeric id including body" do
    get api_v1_word_url(@word.id), headers: auth_headers
    assert_response :success

    word_json = json['word']
    assert_equal @word.id, word_json['id']
    assert_equal @word.title, word_json['title']
    assert_not_nil word_json['body']
    assert_not_nil word_json['body_html']
  end

  test "show returns word by slug" do
    get api_v1_word_url(@word.to_param), headers: auth_headers
    assert_response :success
    assert_equal @word.id, json['word']['id']
  end

  test "show returns 404 for unknown word" do
    get api_v1_word_url('does-not-exist'), headers: auth_headers
    assert_response :not_found
    assert_equal 'Not Found', json['error']
  end

  test "show returns 404 for unknown numeric id" do
    get api_v1_word_url(999_999), headers: auth_headers
    assert_response :not_found
  end

  # -- create --------------------------------------------------------------

  test "create makes a new word and returns 201" do
    assert_difference('Word.count', 1) do
      post api_v1_words_url,
        params: { word: { title: 'API Created Word', body: 'Hello there', tag_list: 'api,test' } },
        headers: auth_headers,
        as: :json
    end

    assert_response :created
    word_json = json['word']
    assert_equal 'API Created Word', word_json['title']
    assert_match 'Hello there', word_json['body']
    assert_includes word_json['tags'], 'api'
    assert_includes word_json['tags'], 'test'
  end

  test "create fails with blank title" do
    assert_no_difference('Word.count') do
      post api_v1_words_url, params: { word: { title: '' } }, headers: auth_headers, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal 'Validation Failed', json['error']
    assert json['details'].any? { |d| d =~ /Title/ }
  end

  test "create fails with duplicate title" do
    assert_no_difference('Word.count') do
      post api_v1_words_url, params: { word: { title: @word.title } }, headers: auth_headers, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal 'Validation Failed', json['error']
  end

  test "create without word param returns parameter missing error" do
    post api_v1_words_url, params: {}, headers: auth_headers, as: :json
    assert_response :bad_request
    assert_equal 'Parameter Missing', json['error']
  end

  # -- update --------------------------------------------------------------

  test "update modifies an existing word" do
    patch api_v1_word_url(@word.id),
      params: { word: { body: 'Updated content', tag_list: 'updated' } },
      headers: auth_headers,
      as: :json

    assert_response :success
    word_json = json['word']
    assert_match 'Updated content', word_json['body']
    assert_includes word_json['tags'], 'updated'

    @word.reload
    assert_match 'Updated content', @word.body.to_s
  end

  test "update by slug works" do
    patch api_v1_word_url(@word.to_param),
      params: { word: { body: 'Updated via slug' } },
      headers: auth_headers,
      as: :json

    assert_response :success
    assert_match 'Updated via slug', json['word']['body']
  end

  test "update fails with blank title" do
    patch api_v1_word_url(@word.id), params: { word: { title: '' } }, headers: auth_headers, as: :json
    assert_response :unprocessable_entity
    assert_equal 'Validation Failed', json['error']
  end

  test "update returns 404 for unknown word" do
    patch api_v1_word_url('does-not-exist'), params: { word: { body: 'x' } }, headers: auth_headers, as: :json
    assert_response :not_found
  end

  # -- destroy ---------------------------------------------------------------

  test "destroy removes the word" do
    assert_difference('Word.count', -1) do
      delete api_v1_word_url(@word.id), headers: auth_headers
    end

    assert_response :success
    assert_equal 'Word deleted successfully', json['message']
  end

  test "destroy returns 404 for unknown word" do
    delete api_v1_word_url('does-not-exist'), headers: auth_headers
    assert_response :not_found
  end

  test "destroy of the protected home page (id 1) fails and does not delete it" do
    home = Word.create!(id: 1, title: 'Protected Home')

    assert_no_difference('Word.count') do
      delete api_v1_word_url(home.id), headers: auth_headers
    end

    assert_response :unprocessable_entity
    assert_equal 'Validation Failed', json['error']
    assert Word.exists?(1)
  end

  # -- search ------------------------------------------------------------

  test "search requires q parameter" do
    get search_api_v1_words_url, headers: auth_headers
    assert_response :bad_request
    assert_equal 'Bad Request', json['error']
  end

  test "search filters words by title or body" do
    Word.delete_all
    matching_title = Word.create!(title: "Special Keyword Page")
    matching_body = Word.create!(title: "Other Page")
    matching_body.body = "contains keyword in body"
    matching_body.save!
    non_matching = Word.create!(title: "Nothing Here")
    non_matching.body = "irrelevant"
    non_matching.save!

    get search_api_v1_words_url, params: { q: 'keyword' }, headers: auth_headers
    assert_response :success

    titles = json['words'].map { |w| w['title'] }
    assert_includes titles, 'Special Keyword Page'
    assert_includes titles, 'Other Page'
    assert_not_includes titles, 'Nothing Here'
    assert_equal 'keyword', json['query']
  end

  test "search paginates results" do
    Word.delete_all
    6.times { |i| Word.create!(title: "Match #{i}") }

    get search_api_v1_words_url, params: { q: 'Match', per_page: 2 }, headers: auth_headers
    assert_response :success
    assert_equal 2, json['words'].size
    assert_equal 3, json['pagination']['total_pages']
  end

  # -- tags ----------------------------------------------------------------

  test "tags lists all tags with counts" do
    Word.delete_all
    Word.create!(title: 'T1', tag_list: 'ruby,rails')
    Word.create!(title: 'T2', tag_list: 'ruby')

    get tags_api_v1_words_url, headers: auth_headers
    assert_response :success

    tags_by_name = json['tags'].index_by { |t| t['name'] }
    assert_equal 2, tags_by_name['ruby']['count']
    assert_equal 1, tags_by_name['rails']['count']
  end

  # -- tagged --------------------------------------------------------------

  test "tagged returns words with the given tag" do
    Word.delete_all
    tagged_word = Word.create!(title: 'Tagged Word', tag_list: 'featured')
    Word.create!(title: 'Untagged Word')

    get api_v1_words_tagged_url(tag: 'featured'), headers: auth_headers
    assert_response :success

    assert_equal 'featured', json['tag']
    titles = json['words'].map { |w| w['title'] }
    assert_equal [tagged_word.title], titles
  end

  test "tagged returns empty list for unknown tag" do
    get api_v1_words_tagged_url(tag: 'no-such-tag'), headers: auth_headers
    assert_response :success
    assert_equal [], json['words']
  end

  # -- authentication (integration with BaseController) --------------------

  test "requests without a token are rejected with JSON 401" do
    get api_v1_words_url
    assert_response :unauthorized
    assert_equal 'json', @response.media_type.split('/').last
    assert_equal 'Unauthorized', json['error']
  end

  test "requests with an invalid token are rejected with JSON 401" do
    get api_v1_words_url, headers: auth_headers('not-a-real-token')
    assert_response :unauthorized
    assert_equal 'Unauthorized', json['error']
  end
end
