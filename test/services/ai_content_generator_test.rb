require 'test_helper'

class AiContentGeneratorTest < ActiveSupport::TestCase
  ENDPOINT = 'https://api.openai.com/v1/responses'

  test "fails without making a request when no API key is configured" do
    never_called = ->(*) { flunk 'Faraday.new should not be called when the API key is missing' }

    result = nil
    with_stubbed_singleton_method(Faraday, :new, never_called) do
      result = AiContentGenerator.new('Ruby').call
    end

    assert_not result.success?
    assert_nil result.content
    assert_match(/not configured/i, result.error)
  end

  test "posts the prompt id and word title as input, with a bearer auth header" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    request = nil
    stubs.post(ENDPOINT) do |env|
      request = env
      [200, { 'Content-Type' => 'application/json' }, { output: [{ content: [{ text: 'hello' }] }] }.to_json]
    end

    result = nil
    stub_faraday_new(stubs) do
      result = AiContentGenerator.new('Ruby').call
    end

    assert result.success?
    body = JSON.parse(request.request_body)
    assert_equal AiContentGenerator::PROMPT_ID, body.dig('prompt', 'id')
    assert_equal 'Ruby', body['input']
    assert_equal 'Bearer sk-test-123', request.request_headers['Authorization']
    assert_equal 'application/json', request.request_headers['Content-Type']

    stubs.verify_stubbed_calls
  end

  test "parses content from the output/content/text response shape and converts newlines to <br>" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) do |_env|
      [200, {}, { output: [{ content: [{ text: "line one\nline two" }] }] }.to_json]
    end

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert result.success?
    assert_equal "line one<br>line two", result.content
    assert_nil result.error
  end

  test "parses content from the choices/message/content response shape" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) do |_env|
      [200, {}, { choices: [{ message: { content: 'chat style content' } }] }.to_json]
    end

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert result.success?
    assert_equal 'chat style content', result.content
  end

  test "returns a failure result when the response body has no recognizable content" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) { |_env| [200, {}, { unexpected: 'shape' }.to_json] }

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert result.success?
    assert_match(/API returned empty content/, result.content)
  end

  test "returns a friendly message for a 401 response" do
    Option.openai_api_key = 'bad-key'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) { |_env| [401, {}, '{}'] }

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert_not result.success?
    assert_match(/invalid api key/i, result.error)
  end

  test "returns a friendly message for a 429 rate-limited response" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) { |_env| [429, {}, '{}'] }

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert_not result.success?
    assert_match(/rate limit/i, result.error)
  end

  test "surfaces the API's own error message for other failure statuses" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) { |_env| [400, {}, { error: { message: 'Bad request details' } }.to_json] }

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert_not result.success?
    assert_equal 'API Error: Bad request details', result.error
  end

  test "returns a network error message when the HTTP call raises a Faraday error" do
    Option.openai_api_key = 'sk-test-123'

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post(ENDPOINT) { raise Faraday::ConnectionFailed, 'connection reset' }

    result = nil
    stub_faraday_new(stubs) { result = AiContentGenerator.new('Ruby').call }

    assert_not result.success?
    assert_match(/network error/i, result.error)
    assert_match(/connection reset/, result.error)
  end
end
