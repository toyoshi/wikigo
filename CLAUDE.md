# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WikiGo is a multi-user wiki engine built with Ruby on Rails 6.0. It features automatic keyword linking, tagging, versioning, and webhook integrations. The application uses Devise for authentication, ActionText for rich text editing, and supports image uploads via Cloudinary.

## Development Commands

### Setup and Dependencies
- `bundle install` - Install Ruby gems
- `yarn install` - Install JavaScript dependencies
- `rails db:migrate` - Run database migrations
- `rails db:seed` - Seed the database

### Running the Application
- `rails server` or `rails s` - Start the development server
- `bin/webpack-dev-server` - Start the webpack development server (for asset compilation)

### Testing
- `rails test` - Run the full test suite
- `rails test test/models/word_test.rb` - Run specific test file
- `guard` - Run Guard for continuous testing (configured in Guardfile)

### Code Quality
- `rubocop` - Run Ruby linting
- `rubocop -a` - Auto-correct Ruby style issues

### Asset Management
- `rails assets:precompile` - Precompile assets for production
- `yarn build` - Build JavaScript assets via Webpacker

### Docker Development
- `docker-compose up` - Start the application with SQLite database
- `docker-compose build` - Build Docker images
- `docker-compose down` - Stop and remove containers
- `docker-compose exec app rails c` - Access Rails console in container
- `docker-compose exec app rails db:seed` - Seed database in container

## Architecture Overview

### Core Models
- **Word**: Central content model with title, body (ActionText), tags, and versioning via PaperTrail
- **User**: Authentication via Devise, includes admin role and username
- **Webhook**: Integration endpoints for external services
- **Attachment**: File upload handling

### Key Features
- **Service Objects**: Business logic encapsulated in `app/services/` (Words::Create, Words::Update, Webhooks::Send)
- **Versioning**: PaperTrail integration for Word model changes with rollback capability
- **Tagging**: acts-as-taggable-on gem for flexible tagging system
- **Activity Tracking**: PublicActivity gem for user action logging
- **Favorites**: acts_as_favable gem for user favorites

### Controllers Structure
- Words are accessed via custom routes (root path serves Word#show with id: 1)
- Version history accessible at `/:word_id/versions/:version_id`
- Settings area includes site configuration, webhooks, and user management
- Authentication handled via Devise with custom registration controller

### Database
- Uses SQLite3 in development, PostgreSQL in production
- Paper Trail for versioning, acts-as-taggable-on for tags
- ActionText tables for rich text content

### Frontend
- Slim templates for views
- Webpacker for JavaScript bundling
- jQuery and jQuery UI for interactions
- Bootstrap-based theme (Honoka Rails)
- Tag-it plugin for tag input interface

### Configuration
- Environment-specific settings in `config/environments/`
- Cloudinary integration for image uploads (requires CLOUDINARY_URL env var)
- Webhooks configurable per installation
- Theme system with view path prepending
- Claude Code auto-approval enabled for bash commands (`.claude/settings.json`)