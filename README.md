![Build](https://github.com/abhchand/simplee-food/actions/workflows/build.yml/badge.svg)

[![Docker Hub](https://img.shields.io/docker/pulls/abhchand/simplee_food)](https://hub.docker.com/r/abhchand/simplee_food)


# SimpleeFood

SimpleeFood is a self-hosted recipe app.

Simple to run. Simple to use. Simply no bloat.

<img src="https://github.com/abhchand/simplee-food/blob/main/doc/images/simplee-food-recipe-list.png?raw=true" width="300px" />

<img src="https://github.com/abhchand/simplee-food/blob/main/doc/images/simplee-food-recipe.png?raw=true" width="300px" />

## Quick Start

SimpleeFood is packaged as a docker image and can be run with `docker compose`.

```shell
# optional: specify which image tag to use
# defaults to "latest"
export SIMPLEE_FOOD_DOCKER_TAG="v1.0.0"

# fetch the sample `docker-compose.yml` file in this repo
curl "https://raw.githubusercontent.com/abhchand/simplee-food/refs/heads/main/docker-compose.yml" > docker-compose.yml

# start the application
docker compose up
```

* View the application at http://localhost:8080/.
* Log in with username `admin` and password `sekrit`. You can update this from the [`/settings`](http://localhost:8080/settings) page.
* See [docker hub](https://hub.docker.com/r/abhchand/simplee_food/tags) for the list of available tags


## Updating

```shell
# optional: specify which new image tag to use
# defaults to "latest"
export SIMPLEE_FOOD_DOCKER_TAG="v2.0.0"

# fetch the image
docker compose pull

# rebuild and restart
docker compose down
docker compose up --build --force-recreate
```

## Configuration

SimpleeFood respects the following environment variables, if set:

ENV Var | Description
--- | ---
`SIMPLEE_FOOD_APP_PORT` | Serve the application on a specific port. (default: `8080`)
`SIMPLEE_FOOD_DOCKER_TAG` | Specify a tag for the docker image (default: `latest`). [See available tags](https://hub.docker.com/repository/docker/abhchand/simplee_food/tags).

## Data Backup + Restore

All recipe data is stored in a single, self-contained [SQLite](https://www.sqlite.org/index.html) DB file, which can be easily backed up or restored.

```
sqlite/simplee_food.production.sqlite3
```

## Support

Questions? Need help? [Open an issue](https://github.com/abhchand/simplee-food/issues) on Github.

## Development

Interested in contributing to SimpleeFood or running it locally in development mode?

See [`DEVELOPMENT.md`](DEVELOPMENT.md).
