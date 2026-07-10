# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WikiGo is a multi-user wiki engine built with Ruby on Rails 8 (Ruby 3.3). Its signature feature is automatic keyword linking: any page title mentioned in another page's content becomes a link. It also provides tagging, versioning, webhooks, a REST API, and AI-assisted content editing. Authentication is Devise; rich text is ActionText/Trix.

## Development Commands

### Setup and Dependencies
- `bundle install` - Install Ruby gems
- `rails db:prepare` - Create/migrate the database
- `rails db:seed` - Seed the database

### Running the Application
- `rails server` - Start the development server (no separate JS build step; importmap + Propshaft)

### Testing
- `rails test` - Run the full test suite (Minitest)
- `rails test test/models/word_test.rb` - Run specific test file

### Security
- `bundle-audit check --update` - Audit gems for known CVEs (also runs in CI)

### Docker
- `docker-compose up` - Start the application with SQLite database
- `docker-compose exec app rails c` - Rails console in container

### CI
- GitHub Actions (`.github/workflows/ci.yml`) runs `rails test` and `bundle-audit` on push/PR.

## Architecture Overview

### Core Models
- **Word**: Central content model with title, body (ActionText), tags, and versioning via PaperTrail
- **User**: Devise authentication, admin role, username
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
- Slim templates
- Propshaft asset pipeline + importmap-rails (no Node/Webpacker)
- Hotwire (Turbo + Stimulus)
- Bootstrap 5.3 via dartsass-rails
