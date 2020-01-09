FROM ruby:2.5

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client cmake libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY Gemfile* /src/
RUN bundle install
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]