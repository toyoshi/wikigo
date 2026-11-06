# Example branch wiring (#117): plug the real OpenAI provider into the
# AiContentGenerator seam that main models with its deterministic Fake.
#
# This is the whole "enable a vendor provider" story: one line against the
# public seam. Requests then hit OpenAI with the key from the settings page
# (Option.openai_api_key — encrypted at rest since #113).
Rails.application.config.after_initialize do
  AiContentGenerator.provider = AiContentGenerator::OpenAi
end
