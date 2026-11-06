# Changelog

WikiGo is a **Rails reference app**: its releases pin *which Rails's way of
writing* the codebase demonstrates, so a reader can always check out a tag
and know exactly which Ruby/Rails idioms the code models. The `main` branch
floats forward with the framework; **tags are the stable citation**.

The format follows [Keep a Changelog](https://keepachangelog.org/); versions
follow semver where it applies to the wiki feature set, and every release
section opens with its reference point (Ruby/Rails versions — `Gemfile.lock`
at that tag is the source of truth).

## [Unreleased]

Follows Rails 8.1.x as `main` moves; see the issue ledger for shape.

## [0.1.0] - 2026-11-06 — the Rails 8.1 reference point

**Reference point:** Ruby 4.0.8 / Rails 8.1.4.1.

### The Rails 8.1 types this codebase models
- **Solid Cache / Solid Cable / Solid Queue** — the no-Redis database-backed
  trio; webhook delivery is a real ActiveJob on the queue database (#112)
- **Attribute encryption** — `Option#encrypts :option_value`, keys via the
  credentials mechanism (#113)
- **Authentication generator** — `has_secure_password` + server-side
  `Session` records replace Devise (#110); sign-in is an end-to-end system
  journey (#115)
- **ActiveJob** — `ApplicationJob` with `retry_on`, the `:test` adapter and
  `perform_enqueued_jobs` as the tested pattern
- **ActiveModel::Attributes** — `Setting` as the form-object exemplar over an
  explicit `Option::KNOWN_KEYS` registry; no `method_missing` dispatch (#114)
- **Health checks & Kamal** — `/up` via `Rails::HealthController`,
  `kamal.yml.sample` + build-time asset precompile (#111)
- **Local CI** — `bin/ci` (setup, gem audit, brakeman, tests, seeds, system)
  as the pre-push gate; structured event reporter on `Rails.event.notify`

### Reference discipline adopted at this point
- The README carries the 採用/non-goals contract with issue-tracked evidence;
  vendored account-specific surface (OpenAI) lives behind the
  `AiContentGenerator` provider seam, the implementation on the
  `example/ai-editing` branch (#117)
- Legacy schema columns removed outright, no shims (#116)
- Dependabot policy in-tree; security alerts triaged, not auto-merged (#108)

### Fixed in the lead-up
- Version-history deserialization (PaperTrail JSON serializer; Psych
  `DisallowedClass`) — #82
- `body_plain_text` search indexing + `body_snapshot` history rendering,
  rollback rewritten snapshot-first — #83
- Blank-registration-token privilege path — #103-era audit
