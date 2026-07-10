require 'test_helper'

class WebhooksSendTest < ActiveSupport::TestCase
  setup do
    @user = users(:john)
    @word = Word.first
    Webhook.delete_all

    # Rails.application.routes.default_url_options is process-global mutable
    # state (ApplicationController#set_host writes to it on every web
    # request). Reset it around each test so these tests are deterministic
    # regardless of what other tests ran before them in this process, and so
    # they exercise the same "no ambient request host" situation that a
    # console/job/API-only invocation of Webhooks::Send would see.
    @original_default_url_options = Rails.application.routes.default_url_options.dup
    Rails.application.routes.default_url_options.clear
  end

  teardown do
    Rails.application.routes.default_url_options.clear
    Rails.application.routes.default_url_options.merge!(@original_default_url_options)
  end

  test "does nothing when there are no registered webhooks" do
    stubs = Faraday::Adapter::Test::Stubs.new

    stub_faraday_new(stubs) do
      Webhooks::Send.new('create', @word, @user).call
    end

    assert_nothing_raised { stubs.verify_stubbed_calls } # no stubs registered, none should have been called
  end

  test "posts a JSON payload with text, word, and tags to every registered webhook url" do
    Webhook.create!(title: 'Hook One', url: 'https://hooks.example.com/one')
    Webhook.create!(title: 'Hook Two', url: 'https://hooks.example.com/two')
    @word.tag_list.add('foo', 'bar')
    @word.save!

    stubs = Faraday::Adapter::Test::Stubs.new
    requests = []
    stubs.post('https://hooks.example.com/one') { |env| requests << env; [200, {}, ''] }
    stubs.post('https://hooks.example.com/two') { |env| requests << env; [200, {}, ''] }

    stub_faraday_new(stubs) do
      Webhooks::Send.new('create', @word, @user).call
    end

    assert_equal 2, requests.size

    payload = JSON.parse(requests.first.request_body)
    assert_equal %w[text word tags], payload.keys
    assert_includes payload['text'], @user.username
    assert_includes payload['text'], 'created'
    assert_includes payload['text'], @word.title

    word_json = JSON.parse(payload['word'])
    assert_equal @word.id, word_json['id']
    assert_equal @word.title, word_json['title']

    tags_json = JSON.parse(payload['tags'])
    assert_equal @word.tags.map(&:name).sort, tags_json.map { |t| t['name'] }.sort

    stubs.verify_stubbed_calls
  end

  test "uses 'updated' wording in the message for the update action" do
    Webhook.create!(title: 'Hook One', url: 'https://hooks.example.com/one')

    stubs = Faraday::Adapter::Test::Stubs.new
    request = nil
    stubs.post('https://hooks.example.com/one') { |env| request = env; [200, {}, ''] }

    stub_faraday_new(stubs) do
      Webhooks::Send.new('update', @word, @user).call
    end

    payload = JSON.parse(request.request_body)
    assert_includes payload['text'], 'updated'
    refute_includes payload['text'], 'created'
  end

  test "rescues errors from an individual webhook so the others still fire" do
    Webhook.create!(title: 'Broken', url: 'https://hooks.example.com/broken')
    Webhook.create!(title: 'Fine', url: 'https://hooks.example.com/fine')

    stubs = Faraday::Adapter::Test::Stubs.new
    fine_called = false
    stubs.post('https://hooks.example.com/broken') { raise Faraday::ConnectionFailed, 'boom' }
    stubs.post('https://hooks.example.com/fine') { fine_called = true; [200, {}, ''] }

    stub_faraday_new(stubs) do
      Webhooks::Send.new('create', @word, @user).call
    end

    assert fine_called
  end

  test "builds the link even with no ambient request host (e.g. API-only controllers, console, jobs)" do
    # Rails.application.routes.default_url_options[:host] is normally set by
    # ApplicationController#set_host on every web request. It is never set
    # by Api::V1::BaseController (ActionController::API, no ApplicationController
    # ancestor) or by any non-controller caller, so this simulates exactly
    # that situation.
    assert_empty Rails.application.routes.default_url_options

    Webhook.create!(title: 'Hook One', url: 'https://hooks.example.com/one')

    stubs = Faraday::Adapter::Test::Stubs.new
    request = nil
    stubs.post('https://hooks.example.com/one') { |env| request = env; [200, {}, ''] }

    stub_faraday_new(stubs) do
      Webhooks::Send.new('create', @word, @user).call
    end

    payload = JSON.parse(request.request_body)
    assert_match %r{\Ahttp://[^/]+/#{Regexp.escape(@word.title)}\z}, payload['text'][/<([^|]+) \|/, 1].strip
  end
end
