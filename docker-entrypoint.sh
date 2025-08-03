#!/bin/sh
set -e

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting WikiGo application..."

# Ensure bundle is up to date
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ensuring bundle is up to date..."
bundle check || bundle install

# Wait for database to be ready (if needed)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking database connectivity..."

# Create database if it doesn't exist
if [ ! -f db/development.sqlite3 ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating database..."
  bundle exec rails db:create
fi

# Run database migrations
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running database migrations..."
bundle exec rails db:migrate

# Seed database if empty (only in development or when explicitly requested)
if [ "${RAILS_SEED:-false}" = "true" ] || [ "$RAILS_ENV" = "development" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Seeding database..."
  bundle exec rails db:seed
fi

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