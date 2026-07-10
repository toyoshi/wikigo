ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'faraday'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  fixtures 'acts_as_taggable_on/tags'
  fixtures 'acts_as_taggable_on/taggings'

  # Add more helper methods to be used by all tests here...

  # Temporarily replaces a singleton method (e.g. a class method) on
  # +receiver+ with +replacement+ (a callable) for the duration of the
  # block, then restores the original implementation, even if the block
  # raises. The stubbed method forwards whatever arguments/block it is
  # called with to +replacement+.
  #
  # This app's minitest (6.x) no longer bundles Minitest::Mock, so
  # Object#stub isn't available here; this is a small hand-rolled stand-in
  # for that one piece of it.
  def with_stubbed_singleton_method(receiver, method_name, replacement)
    metaclass = receiver.singleton_class
    original_name = :"__test_stub_original_#{method_name}_#{receiver.object_id}"
    metaclass.send(:alias_method, original_name, method_name)
    metaclass.send(:define_method, method_name) do |*args, &blk|
      replacement.call(*args, &blk)
    end

    yield
  ensure
    metaclass.send(:remove_method, method_name)
    metaclass.send(:alias_method, method_name, original_name)
    metaclass.send(:remove_method, original_name)
  end

  # Runs the block with Faraday.new stubbed so that every Faraday connection
  # created inside it (regardless of whether it's built with `Faraday.new(url)`,
  # `Faraday.new { |conn| ... }`, or both) uses Faraday's built-in Test adapter
  # against +stubs+ instead of performing real HTTP requests.
  #
  # Any adapter explicitly configured inside a `Faraday.new` block (e.g. via
  # `conn.adapter Faraday.default_adapter`) is overridden with the test
  # adapter afterwards, so services do not need to be aware they're under test.
  def stub_faraday_new(stubs)
    original_new = Faraday.method(:new)

    fake_new = lambda do |*args, &blk|
      original_new.call(*args) do |conn|
        blk.call(conn) if blk
        conn.adapter :test, stubs
      end
    end

    with_stubbed_singleton_method(Faraday, :new, fake_new) { yield }
  end
end
