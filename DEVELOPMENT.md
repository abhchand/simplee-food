## Development

SimpleeFood uses [Sinatra Ruby](https://sinatrarb.com/) for the backend and [rollup.js](https://github.com/rollup/rollup) for the frontend.

The easiest way to run the project is with the official docker image ([instructions](README.md)). However,
if you wish to contribute to it you can run the application locally in `development` mode.

### Pre-Requisites

You must have the following installed -
  * The ruby version specified in [`.ruby-version`](./.ruby-version).
  * The node version specified in [`.nvmrc`](./.nvmrc), along with [`yarn`](https://yarnpkg.com/).
  * [`ImageMagick`](https://imagemagick.org/) to process images. Install with `sudo apt install imagemagick` (Debian) or `brew install imagemagick` (OSX)

Optionally, [`rvm`](https://rvm.io/) is a tool to help manage multiple ruby versions and [`nvm`](https://github.com/nvm-sh/nvm) is a tool to help manage multiple node versions.

### Run

The `bin/app` script provides a convenient wrapper for multiple commands. It's not doing anything complex, it's just running ruby and yarn commands. [See for yourself here](bin/app).

```shell
# One-time setup - creates the DB, runs migrations, etc...
bin/app setup

# Start the frontend and backend in different terminal windows
bin/app backend
bin/app frontend
```

* View the application at http://localhost:9292/.
* Log in with username `indra` and password `sekrit`.
* You can change the username/password or add new users from the `/settings` page.

### Sinatra Console

You can access the Sinatra ruby console with:

```shell
bin/app console
```

### Migrations

If you make DB changes you will have to migrate the schema manually.

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

Run linting with:

```shell
yarn run lint
```

This runs `stylelint`, `prettier`, etc.. See [`package.json`](package.json).

### DB Reset

It's occassionally useful to drop all application data and re-build the application with newly seeded data.

All data is stored in a single [SQLite](https://www.sqlite.org/index.html) DB file. Just delete it -

```shell
rm sqlite/app.development.sqlite3
```

Be sure to run the one-time `bin/app setup` task again since you are starting from scratch.
