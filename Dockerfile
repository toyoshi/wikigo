FROM ruby:3.2-alpine

# Install system dependencies for Alpine
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    sqlite-dev \
    nodejs \
    npm \
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

# Copy and make entrypoint script executable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh", "-c", "rails server -b 0.0.0.0 -p ${PORT:-3000}"]