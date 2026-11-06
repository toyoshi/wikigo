# AI Editing with a real OpenAI provider (example branch)

main keeps `AiContentGenerator` at its interface plus a deterministic
`Fake` provider (#117) — the Rails lesson is the provider seam, not a vendor
account. This branch demonstrates a production provider plugged into that
seam, and is the right shape for any other vendor.

## What this branch adds

| Piece | Role |
| --- | --- |
| `app/services/ai_content_generator/open_ai.rb` | The vendor half: Faraday POST, prompt reference, response-shape tolerance, the HTTP error taxonomy |
| `config/initializers/ai_editing.rb` | One line against the public seam: `AiContentGenerator.provider = AiContentGenerator::OpenAi` (deferred via `after_initialize`) |
| `Option` registry + settings field | `openai_api_key`, encrypted at rest via the #113 mechanism |
| `test/services/ai_content_generator/open_ai_test.rb` | The WebMock suite exercising the live-path contract offline |

## Enabling it

```bash
git fetch origin example/ai-editing
git checkout example/ai-editing
bin/setup --skip-server
bin/ci
```

Then in the app: Settings → *OpenAI API Key* → save. The AI button on the
word editor now calls OpenAI. Removing the key restores the graceful
"key not configured" result — the feature degrades instead of erroring.

## Why it lives here

The vendor surface (endpoint URLs, prompt ids, API keys, the quirks of a
third-party response shape) changes on someone else's schedule and teaches
nothing about Rails — exactly the class of dependency that cost this repo
real churn before (#101). main models the seam; the branch models one
implementation of it, so readers can see both halves without either
contaminating the other.
