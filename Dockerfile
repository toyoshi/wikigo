FROM ruby:2.7-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    sqlite-dev \
    nodejs \
    git \
    curl \
    tzdata \
    libxml2-dev \
    libxslt-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /src

# Update RubyGems and Bundler
RUN gem update --system 3.3.22 && gem install bundler

# Copy dependency files first for better caching
COPY Gemfile ./

# Install Ruby gems
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Copy and set entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]