![Build](https://github.com/abhchand/simplee-food/actions/workflows/build.yml/badge.svg)

[![Docker Hub](https://img.shields.io/docker/pulls/abhchand/simplee_food)](https://hub.docker.com/r/abhchand/simplee_food)


# SimpleeFood

SimpleeFood is self-hosted recipe app.

Simple to run. Simple to use. Simply no bloat.

## Quick Start

Run the app with `docker compose` (which pulls from [docker hub](https://hub.docker.com/repository/docker/abhchand/simplee_food))

```shell
# download the latest `docker-compose.yml` file in this repo
curl "https://raw.githubusercontent.com/abhchand/simplee-food/refs/heads/main/docker-compose.yml" > docker-compose.yml

# start the application
docker compose up
```

* View the application at http://localhost:8080/.
* Log in with username `admin` and password `sekrit`.
* You can change the username/password or add new users from the `/settings` page.

## Updating

```shell
docker compose pull

docker compose down
docker compose up --build --force-recreate
```

### Configuration

SimpleeFood respects the following environment variables, if set:

ENV Var | Description
--- | ---
`SIMPLEE_FOOD_APP_PORT` | Serve the application on a specific port. (default: `8080`)
`SIMPLEE_FOOD_DOCKER_TAG` | Specify a tag for the docker image (default: `latest`). [See available tags](https://hub.docker.com/repository/docker/abhchand/simplee_food/tags).

### Backing up and Restoring Data

All recipe data is stored in a single, self-contained [SQLite](https://www.sqlite.org/index.html) DB file, which can be easily backed up or restored.

```
sqlite/simplee_food.production.sqlite3
```

## Development

Interested in contributing to SimpleeFood or running it locally in development mode?

See [`DEVELOPMENT.md`](DEVELOPMENT.md).
