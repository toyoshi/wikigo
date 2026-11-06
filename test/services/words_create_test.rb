require 'test_helper'

class WordsCreateTest < ActiveSupport::TestCase
  setup do
    @john = users(:john)
    Webhook.delete_all # avoid sending webhooks unless a test explicitly registers one
  end

  test "saves the word and returns a successful result" do
    result = Words::Create.new(@john, { title: 'Brand New Word', body: 'hello' }).call

    assert result.success?
    assert result.word.persisted?
    assert_equal 'Brand New Word', result.word.title
  end

  test "returns an unsuccessful result and does not persist an invalid word" do
    assert_no_difference('Word.count') do
      result = Words::Create.new(@john, { title: '', body: 'hello' }).call

      assert_not result.success?
      assert_not result.word.persisted?
      assert result.word.errors[:title].present?
    end
  end

  test "does not allow creating a word with a duplicate title" do
    existing = Word.first

    assert_no_difference('Word.count') do
      result = Words::Create.new(@john, { title: existing.title }).call

      assert_not result.success?
    end
  end

  test "adds the creator as a favorite of the new word" do
    result = Words::Create.new(@john, { title: 'Favorited On Create' }).call

    assert result.success?
    assert result.word.favorites.exists?(user: @john)
  end

  test "does not add a favorite when creation fails" do
    result = Words::Create.new(@john, { title: '' }).call

    assert_not result.success?
    assert_empty result.word.favorites
  end

  test "sends a webhook to each registered endpoint on success" do
    Webhook.create!(title: 'Hook One', url: 'https://hooks.example.com/one')
    Webhook.create!(title: 'Hook Two', url: 'https://hooks.example.com/two')

    stubs = Faraday::Adapter::Test::Stubs.new
    requests = []
    stubs.post('https://hooks.example.com/one') { |env| requests << env; [200, {}, ''] }
    stubs.post('https://hooks.example.com/two') { |env| requests << env; [200, {}, ''] }

    result = nil
    stub_faraday_new(stubs) do
      # Webhooks::SendJob runs inline here; in production the Solid Queue
      # dispatcher picks it up off the queue database.
      perform_enqueued_jobs do
        result = Words::Create.new(@john, { title: 'Webhook Word' }).call
      end
    end

    assert result.success?
    assert_equal 2, requests.size

    payload = JSON.parse(requests.first.request_body)
    assert_includes payload['text'], @john.username
    assert_includes payload['text'], 'created'
    assert_equal 'Webhook Word', JSON.parse(payload['word'])['title']

    stubs.verify_stubbed_calls
  end

  test "does not send a webhook when creation fails" do
    Webhook.create!(title: 'Hook One', url: 'https://hooks.example.com/one')

    result = nil
    assert_no_enqueued_jobs do
      result = Words::Create.new(@john, { title: '' }).call
    end

    assert_not result.success?
  end

  # The before_commit gate on Word (#137): the queue lives in a separate
  # database, so a job enqueued before a rollback could never be unsent.
  test "does not enqueue the webhook when the caller's transaction rolls back" do
    assert_no_enqueued_jobs do
      ActiveRecord::Base.transaction do
        Words::Create.new(@john, { title: 'Rolled Back Webhook Word' }).call
        raise ActiveRecord::Rollback
      end
    end
  end

  test "enqueues the webhook when the caller's transaction commits" do
    assert_enqueued_jobs(1, only: Webhooks::SendJob) do
      ActiveRecord::Base.transaction do
        Words::Create.new(@john, { title: 'Committed Webhook Word' }).call
      end
    end
  end
end
