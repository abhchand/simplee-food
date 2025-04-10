![Build](https://github.com/abhchand/simplee-food/actions/workflows/test.yml/badge.svg)

# SimpleeFood

SimpleeFood is a simple, no-frills recipe application to self host your recipes.

Most Recipe applications are over-complicated and bloated with unnecessary features. SimpleeFood emphasizes a simple design, minimal functionality, and an easy to run application.

## Quick Start

SimpleeFood uses [docker](https://www.docker.com/get-started/) and [docker compose](https://docs.docker.com/compose/) to run a container-ized application.

```shell
# Clone this repo
git clone git@github.com:abhchand/simplee-food.git
cd simplee-food/

# Start the application
docker compose up
```

Visit http://localhost:8080/ in your browser to view the application.

You can log in with username `admin` and password `sekrit`. You can rename your user or add new users from the "settings" page.

## Updating

When updating SimpleeFood, be sure to `git pull` and force re-build the docker image first.

```shell
git pull
docker compose build --no-cache

# Start the application
docker compose up
```

### Configuration

SimpleeFood respects the following environment variables, if set:

ENV Var | Description
--- | ---
`SIMPLEE_FOOD_APP_PORT` | Serve the application on a specific port. (default: `8080`)
`SIMPLEE_FOOD_DOCKER_TAG` | Specify a tag for the docker image (default: `latest`)
`SIMPLEE_FOOD_SESSION_SECRET` | Specify a custom application secret that will be used to encrypt sessions. If none is specified, one will be generated on application startup and cached in the DB

### Backing up and Restoring Data

All recipe data is stored in a single, self-contained [SQLite](https://www.sqlite.org/index.html) DB file, which can be easily backed up or restored.

```
sqlite/simplee_food.production.sqlite3
```

## Development

Interested in contributing to SimpleeFood or running it locally in development mode?

See [`DEVELOPMENT.md`](DEVELOPMENT.md).
