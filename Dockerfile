FROM ruby:2.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client ruby2.3-dev pkg-config cmake libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY Gemfile Gemfile.lock /src/
RUN bundle install
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]