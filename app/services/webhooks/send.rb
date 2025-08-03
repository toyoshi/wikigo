module Webhooks
  class Send
    include Rails.application.routes.url_helpers

    def initialize(action, word, user)
      @user = user
      @word = word
      @action = action
    end

    def call
      # Changed from asynchronous background job to synchronous webhook sending
      # Previously used WebhookJob.perform_later but simplified to direct HTTP POST
      # to eliminate SolidQueue dependency and complexity
      Webhook.all.each do |h|
        payload = JSON.generate(
          {
          text: text,
          word: @word.to_json,
          tags: @word.tags.to_json,
        })
        send_webhook(h.url, payload)
      end
    end

    private 

    def send_webhook(url, payload)
      # Direct HTTP POST using Faraday (previously in WebhookJob)
      connection = Faraday.new(url)
      connection.post('', payload)
    rescue => e
      # Log webhook errors but don't block the main operation
      Rails.logger.error "Webhook failed for #{url}: #{e.message}"
    end

    def text
      "#{@user.username} #{action_text}: <#{root_url}#{@word.title} | #{@word.title}>"
    end

    def action_text
      (@action == 'create') ? 'created' : 'updated'
    end
  end
end
