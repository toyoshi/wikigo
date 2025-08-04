class AiContentGenerator
  include ActiveModel::Model
  
  # OpenAI Prompt ID (hardcoded as requested)
  PROMPT_ID = "pmpt_688f59402b808196bd90893a5ea637090582dada22046d28"
  
  def initialize(word_title)
    @word_title = word_title
    @api_key = Option.openai_api_key
  end
  
  def call
    return failure_result("OpenAI API key not configured") if @api_key.blank?
    
    begin
      response = make_api_request
      
      if response.success?
        content = parse_response(response.body)
        success_result(content)
      else
        error_message = parse_error_response(response)
        failure_result(error_message)
      end
    rescue Faraday::Error => e
      failure_result("Network error: #{e.message}")
    rescue => e
      failure_result("Unexpected error: #{e.message}")
    end
  end
  
  private
  
  def make_api_request
    connection = Faraday.new do |conn|
      conn.headers['Content-Type'] = 'application/json'
      conn.headers['Authorization'] = "Bearer #{@api_key}"
      conn.adapter Faraday.default_adapter
    end
    
    payload = {
      prompt: {
        id: PROMPT_ID
      },
      input: @word_title
    }
    
    connection.post('https://api.openai.com/v1/responses', payload.to_json)
  end
  
  def parse_response(response_body)
    parsed = JSON.parse(response_body)
    
    # Log the actual response for debugging
    Rails.logger.info "OpenAI API Response: #{parsed.inspect}"
    
    # Try various possible response structures
    content = parsed.dig('choices', 0, 'message', 'content') ||
              parsed.dig('choices', 0, 'text') ||
              parsed.dig('output', 0, 'content', 0, 'text') ||
              parsed.dig('data', 'response') ||
              parsed['response'] || 
              parsed['content'] ||
              parsed.dig('output', 'content')
    
    if content.present?
      # Preserve line breaks by converting \n to HTML line breaks for ActionText
      content.gsub(/\n/, '<br>')
    else
      Rails.logger.warn "Could not find content in API response: #{parsed.inspect}"
      "API returned empty content. Response structure: #{parsed.keys.join(', ')}"
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}, Body: #{response_body}"
    "Error parsing AI response: #{e.message}"
  end
  
  def parse_error_response(response)
    case response.status
    when 401
      "Invalid API key. Please check your OpenAI API key in Settings."
    when 403
      "Access forbidden. Your API key may not have the required permissions."
    when 429
      "Rate limit exceeded. Please try again later."
    when 404
      "API endpoint not found. The prompt ID may be invalid."
    when 500..599
      "OpenAI server error. Please try again later."
    else
      begin
        parsed = JSON.parse(response.body)
        error_msg = parsed.dig('error', 'message') || 
                   parsed['message'] || 
                   "API request failed"
        "API Error: #{error_msg}"
      rescue JSON::ParserError
        "API request failed with status #{response.status}"
      end
    end
  end
  
  def success_result(content)
    OpenStruct.new(
      success?: true,
      content: content,
      error: nil
    )
  end
  
  def failure_result(error_message)
    OpenStruct.new(
      success?: false,
      content: nil,
      error: error_message
    )
  end
end