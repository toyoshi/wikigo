require 'test_helper'

class AiContentGeneratorTest < ActiveSupport::TestCase
  # Captured at class-load: main boots with the Fake installed; the
  # example/ai-editing branch boots with OpenAI. Every test pins the provider
  # it needs and teardown returns to whatever this boot defaulted to, so the
  # file is order-independent on both branches.
  DEFAULT_PROVIDER = AiContentGenerator.provider

  teardown do
    AiContentGenerator.provider = DEFAULT_PROVIDER
  end

  test "ships a deterministic fake provider so the feature works keyless" do
    AiContentGenerator.provider = AiContentGenerator::Fake
    result = AiContentGenerator.new('Ruby').call

    assert result.success?
    assert_includes result.content, 'Ruby'
    assert_includes result.content, '<br>' # newline contract matches the real provider
  end

  test "the fake fails a blank title rather than inventing content" do
    AiContentGenerator.provider = AiContentGenerator::Fake
    result = AiContentGenerator.new('').call

    assert_not result.success?
    assert_equal 'A word title is required', result.error
  end

  test "the controller contract is the provider seam" do
    provider = Class.new do
      def initialize(word_title)
        @word_title = word_title
      end

      def call
        AiContentGenerator::Result.new(true, "custom:#{@word_title}", nil)
      end
    end

    AiContentGenerator.provider = provider
    result = AiContentGenerator.new('Seam').call

    assert result.success?
    assert_equal 'custom:Seam', result.content
  end

  test "a provider that raises becomes a failed result, never an exception" do
    exploding = Class.new do
      def initialize(word_title); end

      def call
        raise 'connection reset'
      end
    end

    AiContentGenerator.provider = exploding
    result = AiContentGenerator.new('Boom').call

    assert_not result.success?
    assert_includes result.error, 'connection reset'
  end
end
