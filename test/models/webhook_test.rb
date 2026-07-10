require 'test_helper'

class WebhookTest < ActiveSupport::TestCase
  test "valid with a title and url" do
    webhook = Webhook.new(title: "Slack", url: "https://example.com/hook")
    assert webhook.valid?
  end

  test "valid without a title, since only url is required" do
    webhook = Webhook.new(url: "https://example.com/hook")
    assert webhook.valid?
  end

  test "invalid without a url" do
    webhook = Webhook.new(title: "Slack", url: nil)
    assert_not webhook.valid?
    assert_includes webhook.errors[:url], "can't be blank"
  end

  test "invalid with a blank url" do
    webhook = Webhook.new(title: "Slack", url: "")
    assert_not webhook.valid?
  end

  test "loads fixtures as valid records" do
    assert webhooks(:one).valid?
    assert webhooks(:two).valid?
  end

  test "can be persisted and retrieved" do
    webhook = Webhook.create!(title: "New Hook", url: "https://example.com/incoming")
    assert_equal webhook, Webhook.find(webhook.id)
  end
end
