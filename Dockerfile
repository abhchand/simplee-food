FROM ruby:3.0.0-slim-buster

# Configure working directory
RUN mkdir /server
WORKDIR /server

COPY entrypoint.sh /usr/bin/
COPY Gemfile Gemfile.lock /server/
COPY package.json yarn.lock /server/

#
# Ruby
#

RUN apt-get -q update \
  && apt-get install -q -y --no-install-recommends git build-essential curl

RUN bundle config set path /bundle \
  && bundle config set --local without test development \
  && bundle install \
  && apt-get clean -y


#
# Node
#

# NodeJS
# Installing a specific version of node directly is dificult. Use `nvm` to
# install it (which installs both `node` and `npm`)
ENV NODE_VERSION=14.17.5
ENV NVM_DIR=/usr/local/nvm
ENV NVM_VERSION=0.39.3

RUN mkdir -p $NVM_DIR \
  && curl https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && node -v \
  && npm -v

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Yarn
RUN npm install -g yarn && yarn install --check-files --pure-lockfile

COPY . .

ENTRYPOINT ["entrypoint.sh"]

CMD ["rackup", "config.ru", "-p", "8080", "-s", "webrick"]
