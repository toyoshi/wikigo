require 'test_helper'

class EventReporterTest < ActionDispatch::IntegrationTest
  test "log subscriber is registered and receives emitted events" do
    assert Rails.event.subscribers.any? { |entry| entry[:subscriber].is_a?(EventLogSubscriber) },
      "EventLogSubscriber should be registered with Rails.event"
  end

  test "notifying an event emits it to the log subscriber" do
    logged = nil
    subscriber = Object.new
    subscriber.define_singleton_method(:emit) do |event|
      logged = event
    end

    Rails.event.subscribe(subscriber)
    Rails.event.notify("test.wiki_event", word_id: 42)

    assert_equal "test.wiki_event", logged[:name]
    assert_equal({ word_id: 42 }, logged[:payload])
  ensure
    Rails.event.unsubscribe(subscriber)
  end

  test "subscriber without emit is rejected" do
    assert_raise(ArgumentError) do
      Rails.event.subscribe(Object.new)
    end
  end
end
