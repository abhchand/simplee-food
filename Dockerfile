FROM ruby:3.0.0-slim-buster

# Configure working directory
RUN mkdir /server
WORKDIR /server

COPY entrypoint.sh /usr/bin/
COPY Gemfile Gemfile.lock /server/

RUN apt-get -q update \
  && apt-get install -q -y --no-install-recommends git build-essential curl

RUN bundle config set path /bundle \
  && bundle install \
  && apt-get clean -y

COPY . .

ENTRYPOINT ["entrypoint.sh"]

CMD ["rackup", "config.ru", "-p", "8080", "-s", "webrick"]
