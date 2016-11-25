module Webhooks
  class Send
    include Rails.application.routes.url_helpers

    def initialize(action, word, user)
      @user = user
      @word = word
      @action = action
    end

    def call
      Webhook.all.each do |h|
        c = Faraday.new(h.url)
        c.post('', JSON.generate(
          {
            text: text,
            word: @word.to_json,
            tags: @word.tags.to_json,
          }))
      end
    end

    private 

    def text
      "#{@user.username} #{action_text}: <#{root_url}#{@word.title} | #{@word.title}>"
    end

    def action_text
      (@action == 'create') ? 'created' : 'updated'
    end
  end
end
