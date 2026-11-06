# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Purpose:** a simple, modern wiki you can self-host with nothing but Rails and a single Docker command — low operational overhead for teams and individuals to build and grow their own knowledge base.

WikiGo is a multi-user wiki engine built with Ruby on Rails 8 (Ruby 4.0). Its signature feature is automatic keyword linking: any page title mentioned in another page's content becomes a link. It also provides tagging, versioning, webhooks, a REST API, and AI-assisted content editing. Authentication is the Rails 8 authentication generator's stack (`has_secure_password` BCrypt digests + server-side `Session` records; Devise was retired in #110); rich text is ActionText/Trix.

## Development Commands

### Setup and Dependencies
- `bundle install` - Install Ruby gems
- `rails db:prepare` - Create/migrate the database
- `rails db:seed` - Seed the database

### Running the Application
- `rails server` - Start the development server (no separate JS build step; importmap + Propshaft)
- `SOLID_QUEUE_MODE=everything bin/jobs` - Solid Queue worker + dispatcher. The dispatcher's scheduler also fires the recurring tasks declared in `config/recurring.yml` (e.g. `Sessions::CleanupJob`, the daily expired-Session sweep, #138).

### Testing
- `rails test` - Run the full test suite (Minitest)
- `rails test test/models/word_test.rb` - Run specific test file

### Security
- `bundle-audit check --update` - Audit gems for known CVEs (also runs in CI)

### Docker
- `docker-compose up` - Start the application with SQLite database
- `docker-compose exec app rails c` - Rails console in container

### CI
- `bin/ci` - Rails 8.1 Local CI (`config/ci.rb`): runs gem audit, brakeman, tests, and seeds locally.
- GitHub Actions (`.github/workflows/ci.yml`) runs `rails test` and `bundle-audit` on push/PR.

## Releases & the Reference Point

WikiGo is a reference app: **a tag must answer "which Rails's way of writing
is this?"** Releases are how that stays true.

- `main` floats with Rails; **tags are the citation**. The latest tag is the
  reference point readers should pin.
- On a Rails minor bump (or Ruby minor): open the freshness/upgrade PR, merge
  it green, then (1) add a `CHANGELOG.md` section opening with the reference
  point (Ruby/Rails versions, `Gemfile.lock` at the tag = source of truth),
  (2) `git tag -a vMAJOR.MINOR.0 -m "the Rails X.Y reference point"`,
  (3) `git push --tags`, (4) `gh release create` with the changelog section
  verbatim as notes.
- The changelog section — not the git log — is the human record: which types
  were adopted or retired at that point (issue numbers as evidence).

## Architecture Overview

### Core Models
- **Word**: Central content model with title, body (ActionText), tags, and versioning via PaperTrail
- **User**: `has_secure_password` authentication, `has_many :sessions`, admin role, username
- **Webhook**: Integration endpoints for external services
- **Attachment**: File upload handling
- **ApiToken**: Bearer tokens for the REST API

### Key Features
- **Service Objects**: Business logic in `app/services/` (Words::Create, Words::Update, Webhooks::Send, AiContentGenerator)
- **Versioning**: PaperTrail for Word changes with rollback
- **Tagging**: acts-as-taggable-on
- **Activity Tracking**: PublicActivity
- **Favorites**: acts_as_favable
- **REST API**: `app/controllers/api/` — see WikiGo-REST-API-Documentation.md

### Controllers Structure
- Words use custom routes (root path serves Word#show with id: 1)
- Version history at `/:word_id/versions/:version_id`
- Settings area: site configuration, webhooks, user management
- API under `/api/v1` with Bearer token auth

### Database
- SQLite3 in development/test, PostgreSQL in production (Railway)
- Solid Cache / Solid Cable (database-backed; no Redis)

### Frontend
- ERB templates
- Propshaft asset pipeline + importmap-rails (no Node/Webpacker)
- Hotwire (Turbo + Stimulus)
- Bootstrap 5.3 via dartsass-rails
