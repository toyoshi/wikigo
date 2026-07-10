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

    # Generating absolute URLs (root_url) outside of a real request requires
    # a host. ApplicationController#set_host stashes the current request's
    # host on Rails.application.routes.default_url_options, but that never
    # happens for API-only controllers (ActionController::API doesn't inherit
    # ApplicationController) or for any non-controller invocation (console,
    # jobs, tests). Without this, root_url raises
    # "ArgumentError: Missing host to link to!" and the whole word
    # create/update request blows up. Fall back to the host already
    # configured for exactly this purpose (generating absolute URLs outside
    # a request) via action_mailer.default_url_options.
    def default_url_options
      Rails.application.routes.default_url_options.presence ||
        Rails.application.config.action_mailer.default_url_options ||
        {}
    end

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
