FROM ruby:4.0-alpine

# Install system dependencies for Alpine
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    sqlite-dev \
    git \
    curl \
    tzdata \
    libxml2-dev \
    libxslt-dev \
    yaml-dev \
    libffi-dev \
    zlib-dev \
    openssl-dev \
    vips-dev \
    gcompat \
    linux-headers \
    && rm -rf /var/cache/apk/*

WORKDIR /src

# Update RubyGems and Bundler for Rails 8
RUN gem update --system && gem install bundler

# Copy dependency files first for better caching
COPY Gemfile* /src/

# Install Ruby gems
RUN bundle install

# Copy application code
COPY . .

# Run bundle install again to ensure all gems including git sources are available
RUN bundle install

# Precompile assets at build time, not in the entrypoint (#111): a Kamal
# deployment must be a complete, bootable artifact, and the /up health check
# going green immediately depends on it not compiling assets on first request.
# Dummy boot-time credentials only — real ones arrive as runtime secrets.
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy_precompile_only \
    DATABASE_URL=sqlite3:tmp/precompile_dummy.sqlite3 \
    bundle exec rails assets:precompile

# Copy and make entrypoint script executable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh", "-c", "rails server -b 0.0.0.0 -p ${PORT:-3000}"]