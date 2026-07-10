class AiContentGenerator
  include ActiveModel::Model

  # OpenAI Prompt ID (hardcoded as requested)
  PROMPT_ID = "pmpt_688f59402b808196bd90893a5ea637090582dada22046d28"

  API_ENDPOINT = "https://api.openai.com/v1/responses".freeze

  # Response body keys, in priority order, where the generated content may live.
  CONTENT_PATHS = [
    ['choices', 0, 'message', 'content'],
    ['choices', 0, 'text'],
    ['output', 0, 'content', 0, 'text'],
    ['data', 'response'],
    ['response'],
    ['content'],
    ['output', 'content']
  ].freeze

  # HTTP status -> user-facing error message. 5xx is handled separately.
  STATUS_ERRORS = {
    401 => "Invalid API key. Please check your OpenAI API key in Settings.",
    403 => "Access forbidden. Your API key may not have the required permissions.",
    429 => "Rate limit exceeded. Please try again later.",
    404 => "API endpoint not found. The prompt ID may be invalid."
  }.freeze

  Result = Struct.new(:success?, :content, :error)

  def initialize(word_title)
    @word_title = word_title
    @api_key = Option.openai_api_key
  end

  def call
    return failure("OpenAI API key not configured") if @api_key.blank?

    response = request_content
    if response.success?
      success(extract_content(response.body))
    else
      failure(error_message_for(response))
    end
  rescue Faraday::Error => e
    failure("Network error: #{e.message}")
  rescue => e
    failure("Unexpected error: #{e.message}")
  end

  private

  def request_content
    payload = { prompt: { id: PROMPT_ID }, input: @word_title }
    connection.post(API_ENDPOINT, payload.to_json)
  end

  def connection
    Faraday.new do |conn|
      conn.headers['Content-Type'] = 'application/json'
      conn.headers['Authorization'] = "Bearer #{@api_key}"
      conn.adapter Faraday.default_adapter
    end
  end

  # Parses the response body, tolerating the several shapes the OpenAI API
  # may return, and converts newlines to <br> for ActionText.
  def extract_content(response_body)
    parsed = JSON.parse(response_body)
    Rails.logger.info "OpenAI API Response: #{parsed.inspect}"

    # Mirror the original `a || b || c` chain: first non-nil/non-false value.
    content = CONTENT_PATHS.lazy.map { |path| parsed.dig(*path) }.find { |value| value }

    if content.present?
      content.gsub(/\n/, '<br>')
    else
      Rails.logger.warn "Could not find content in API response: #{parsed.inspect}"
      "API returned empty content. Response structure: #{parsed.keys.join(', ')}"
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}, Body: #{response_body}"
    "Error parsing AI response: #{e.message}"
  end

  def error_message_for(response)
    return STATUS_ERRORS[response.status] if STATUS_ERRORS.key?(response.status)
    return "OpenAI server error. Please try again later." if (500..599).cover?(response.status)

    body_error_message(response)
  end

  def body_error_message(response)
    parsed = JSON.parse(response.body)
    error_msg = parsed.dig('error', 'message') || parsed['message'] || "API request failed"
    "API Error: #{error_msg}"
  rescue JSON::ParserError
    "API request failed with status #{response.status}"
  end

  def success(content)
    Result.new(true, content, nil)
  end

  def failure(error_message)
    Result.new(false, nil, error_message)
  end
end
