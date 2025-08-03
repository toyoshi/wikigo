#!/bin/sh
set -e

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting WikiGo application..."

# Ensure bundle is up to date
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ensuring bundle is up to date..."
bundle check || bundle install

# Wait for database to be ready (if needed)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking database connectivity..."

# Create database if it doesn't exist (only for development SQLite)
if [ "$RAILS_ENV" = "development" ] && [ ! -f db/development.sqlite3 ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating database..."
  bundle exec rails db:create
elif [ "$RAILS_ENV" = "production" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating production database if needed..."
  bundle exec rails db:create 2>/dev/null || echo "Database already exists or will be created by Railway"
fi

# Install Solid Cache and Cable in production
if [ "$RAILS_ENV" = "production" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing Solid Cache and Cable..."
  bundle exec rails solid_cache:install 2>/dev/null || echo "Solid Cache already installed"
  bundle exec rails solid_cable:install 2>/dev/null || echo "Solid Cable already installed"
fi

# Run database migrations
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running database migrations..."
bundle exec rails db:migrate

# Seed database in all environments to ensure required data exists
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Seeding database..."
bundle exec rails db:seed

# Precompile assets if needed (development mode)
if [ "$RAILS_ENV" = "production" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Precompiling assets..."
  bundle exec rails assets:precompile
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Rails server..."

# Set default port if not provided by Railway
export PORT=${PORT:-3000}

# Execute the main command
exec "$@"