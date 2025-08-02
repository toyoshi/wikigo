#!/bin/bash

# Exit on any failure
set -e

# Wait for database to be ready (if using external database)
# For SQLite, this is not necessary but harmless

# Run database migrations
echo "Running database migrations..."
rails db:migrate

# Run database seed
echo "Running database seed..."
rails db:seed

# Execute the main command
echo "Starting Rails server..."
exec "$@"