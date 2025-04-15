## Development

On production, SimpleeFood is intended to run inside docker ([instructions](README.md)). However,
if you wish to contribute to it you can run the application locally in `development` mode.

SimpleeFood uses [Sinatra Ruby](https://sinatrarb.com/) for the backend and [rollup.js](https://github.com/rollup/rollup) for the frontend.

### Pre-Requisites

The development environment requires the following:

software | notes
--- | ---
`ruby` | the ruby version specified in [`.ruby-version`](./.ruby-version).
`node` | the node version specified in [`.nvmrc`](./.nvmrc)
[`yarn`](https://yarnpkg.com/) | install with `npm install -g yarn`
  [`ImageMagick`](https://imagemagick.org/) | needed for image processing. Install with `sudo apt install imagemagick` (Debian) or `brew install imagemagick` (OSX)
[`rvm`](https://rvm.io/) (optional) | a tool to help manage multiple ruby versions
[`nvm`](https://github.com/nvm-sh/nvm) (optional) | a tool to help manage multiple node versions


### Helper Script

This repo includes a [`bin/app`](bin/app) script that provides a convenient wrapper for common tasks. This script is used below, but it's not doing anything magical. [See for yourself](bin/app) what it's doing.

Alternately, you can execute those commands yourself directly.

### Run

To run SimpleeFood:

```shell
# One-time setup: installs dependencies, creates the DB, runs migrations, etc...
bin/app setup

# Start the frontend and backend in different terminal windows
bin/app backend
bin/app frontend
```

* View the application at http://localhost:9292/.
* Log in with username `indra` and password `sekrit`. You can update this from the [`/settings`](http://localhost:9292/settings) page.

### Sinatra Console

You can access the Sinatra ruby console with:

```shell
bin/app console
```

### Migrations

If you make DB changes you will need to migrate the schema manually.

Stop the `backend` ruby server and run:

```shell
# Run migrations
bundle exec rake db:migrate

# Start the backend again
bin/app backend
```

### Hot Reloading

Both the frontend and backend processes support hot reloading by default. This makes it easier to see any code changes reflected, without having to restart the server.

* The frontend reloads using the built-in `--watch` functionality provided by `rollup.js`. See the `build:dev` task in `package.json`.
* The backend reloads using `rerun`, which watches for any `*.rb` file changes. See the `bin/app` shell script wrapper, where you can see how it starts the backend Sinatra server.

### Running Tests

SimpleeFood uses [`rspec`](http://rspec.info/) to run tests. It also uses [`capybara`](https://github.com/teamcapybara/capybara) to run Chrome Headless Browser tests (see `spec/features/*`).

```shell
bundle exec rspec
```

### Linting

Run all linters (`styleline`, `prettier`, etc...) with

```shell
yarn run lint
```

See [`package.json`](package.json) for task definition.

### DB Reset

It's occassionally useful to drop all application data and re-build the application with newly seeded data.

All data is stored in a single [SQLite](https://www.sqlite.org/index.html) DB file. Just delete it -

```shell
rm sqlite/app.development.sqlite3
```

Since you're resetting and removing all DB data, you'll have to re-run one-time `bin/app setup` task again before starting your app again.

```shell
bin/app setup     # one time setup
bin/app backend
bin/app frontend
```
