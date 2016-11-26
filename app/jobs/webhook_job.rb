class WebhookJob < ApplicationJob
  queue_as :webhook

  def perform(url, payload)
      c = Faraday.new(url)
      c.post('', payload)
  end
end
