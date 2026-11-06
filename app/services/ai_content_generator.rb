class AiContentGenerator
  include ActiveModel::Model

  # The AI-edit feature, reduced to its interface (#117).
  #
  # A reference app models the seam, not a vendor account: the controller and
  # the JS button talk to this class, the class delegates content production
  # to a pluggable provider, and main ships AiContentGenerator::Fake — an
  # offline, deterministic stand-in so the whole feature is testable and
  # demoable without an API key. The real OpenAI implementation (HTTP, prompt
  # id, status handling) lives on the `example/ai-editing` branch, where the
  # vendor-specific surface belongs.

  Result = Struct.new(:success?, :content, :error)

  # Deterministic provider used by development, tests, and any clone without
  # credentials. Newlines arrive as <br> exactly like the real provider's
  # output so the ActionText contract matches.
  class Fake
    def initialize(word_title)
      @word_title = word_title
    end

    def call
      return Result.new(false, nil, "A word title is required") if @word_title.blank?

      content = [
        "# #{@word_title}",
        "",
        "Welcome to **#{@word_title}**. This page was drafted by the AiContentGenerator::Fake provider.",
        "",
        "## Sections",
        "- Overview",
        "- Details",
        "- See also",
        "",
        "Swap in a real provider with `AiContentGenerator.provider = MyProvider` — see the `example/ai-editing` branch for an OpenAI implementation."
      ].join("\n").gsub("\n", "<br>")

      Result.new(true, content, nil)
    end
  end

  class << self
    attr_accessor :provider
  end

  self.provider = Fake

  def initialize(word_title)
    @word_title = word_title
    @provider = self.class.provider.new(word_title)
  end

  # Provider contract: respond to #call with a Result(success?, content,
  # error). Anything raising is turned into a failed Result so a live
  # provider's network noise can never bubble into a request.
  def call
    @provider.call
  rescue => e
    Result.new(false, nil, "AI generation failed: #{e.message}")
  end
end
