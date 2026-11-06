module Webhooks
  # Delivers word create/update events to every registered Webhook.
  #
  # Enqueued from Words::Create / Words::Update (perform_later). Delivery is
  # best effort: Webhooks::Send already rescues per-url failures so one dead
  # endpoint never blocks the others, and job-level retries cover failures of
  # the run itself (a deploy mid-flight, the database being away).
  class SendJob < ApplicationJob
    retry_on StandardError, wait: 5.seconds, attempts: 3

    def perform(action, word_id, user_id)
      word = Word.find_by(id: word_id)
      user = User.find_by(id: user_id)
      return if word.nil? || user.nil? # the page or account went away meanwhile

      Webhooks::Send.new(action, word, user).call
    end
  end
end
