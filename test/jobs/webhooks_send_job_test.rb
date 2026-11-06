require 'test_helper'

class WebhooksSendJobTest < ActiveSupport::TestCase
  setup do
    Webhook.delete_all
    @user = users(:john)
    @word = Word.create!(title: "Job Word #{Time.now.to_i}")
  end

  test "perform hands the event to Webhooks::Send" do
    delivered = []
    with_stubbed_singleton_method(Webhooks::Send, :new,
      ->(action, word, user) do
        delivered << [action, word.id, user.id]
        Object.new.tap do |double|
          double.define_singleton_method(:call) { :sent }
        end
      end) do
      Webhooks::SendJob.new.perform('create', @word.id, @user.id)
    end

    assert_equal [['create', @word.id, @user.id]], delivered
  end

  test "a word deleted before the job ran is skipped, not raised" do
    word_id = @word.id
    @word.destroy

    assert_nothing_raised do
      Webhooks::SendJob.new.perform('create', word_id, @user.id)
    end
  end

  test "words create enqueues delivery instead of posting inline" do
    Webhook.create!(title: 'Hook', url: 'https://hooks.example.com/x')

    assert_enqueued_jobs(1, only: Webhooks::SendJob) do
      Words::Create.new(@user, title: 'Enqueued Word').call
    end
  end
end
