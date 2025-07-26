FROM ruby:2.7

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install yarn python2 make g++ -y

WORKDIR /src

# Update RubyGems and Bundler for compatibility
RUN gem update --system 3.3.22 && gem install bundler:2.3.22

COPY Gemfile Gemfile.lock package.json yarn.lock /src/
RUN bundle install
RUN yarn install
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]