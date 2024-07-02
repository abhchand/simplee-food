## Development

SimpleeFood uses [Sinatra Ruby](https://sinatrarb.com/) for the backend and [rollup.js](https://github.com/rollup/rollup) for the frontend.

If you wish to contribute to it, you can run it locally in development mode.

### Pre-Requisites

You must have the following installed -
  * The ruby version specified in [`.ruby-version`](./.ruby-version).
  * The node version specified in [`.nvmrc`](./.nvmrc), along with [`yarn`](https://yarnpkg.com/).

Optionally, [`rvm`](https://rvm.io/) is a tool to help manage multiple ruby versions and [`nvm`](https://github.com/nvm-sh/nvm) is a tool to help manage multiple node versions.

### Run

The `bin/app` script provides a convenient wrapper for multiple commands. It's not doing anything complex, you can [see for yourself here](bin/app).


```shell
# One-time setup
bin/app setup

# Start the frontend and backend in different windows
bin/app backend
bin/app frontend
```

Visit http://localhost:9292/ in your browser to view the application.

The default seeded login is `indra` / `sekrit`.

### Sinatra Console

You can access the Sinatra ruby console with:

```shell
bin/app console
```

### Running Tests

SimpleeFood uses [`rspec`](http://rspec.info/) to run tests.

```shell
bundle exec rspec
```

### Linting

The following linting tasks are available via [`yarn` scripts](https://classic.yarnpkg.com/lang/en/docs/cli/run/) -

```shell
yarn run lint:css        # lints *.scss/*.css files
yarn run lint:prettier   # formats Ruby and JS code
```

### DB Reset

It's occassionally useful to drop all application data and re-build the application with newly seeded data.

All data is stored in a single [SQLite](https://www.sqlite.org/index.html) DB file. Just delete it -

```shell
rm sqlite/app.development.sqlite3
```
