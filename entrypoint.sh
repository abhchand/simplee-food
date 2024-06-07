#!/bin/bash

echo "Installing/Checking ruby dependencies"
bundle config set path /bundle
bundle check || bundle install

version=$(bundle exec rake db:version)

if [[ $? -eq 0 ]] && [[ $version != "Current version: 0" ]]; then
  echo "Database exists: running migrations"
  bundle exec rake db:migrate
else
  echo "No database setup: running setup"
  bundle exec rake db:create
  bundle exec rake db:migrate
fi

# Make sure to bail out if db:setup or db:migrate failed
if [[ $? != 0 ]]; then
  exit 1
fi

# Build frontend assets
yarn run build:prod

# Run what's set in CMD in Dockerfile
echo "ready for takeoff 🚀🚀🚀"
if [ $# -gt 0 ]; then
  bundle exec "$@"
fi
