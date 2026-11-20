#!/bin/bash

echo "Installing/Checking ruby dependencies"
bundle config set path /bundle
bundle check || bundle install

# Each step is safe to re-run on every boot:
#   * `db:create` is a no-op if the database already exists
#   * `db:migrate` only runs pending migrations
#   * `create_initial_user` only creates the default user if no users exist
echo "Setting up database"
if ! bundle exec rake db:create db:migrate simplee_food:create_initial_user; then
  echo "Database setup failed"
  exit 1
fi

# Build frontend assets
yarn run build:prod

# Run what's set in CMD in Dockerfile
echo "ready for takeoff 🚀🚀🚀"
if [ $# -gt 0 ]; then
  bundle exec "$@"
fi
