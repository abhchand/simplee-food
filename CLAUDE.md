# SimpleeFood

A self-hosted recipe app. Store, search, tag, and import recipes; read them hands-free
in "cooking mode" on a tablet or phone.

Sinatra + ActiveRecord + SQLite on the backend, server-rendered ERB with plain
ES-module JS bundled by rollup.js on the frontend. Shipped as a single Docker image.

See `README.md` (users) and `doc/DEVELOPMENT.md` (contributors) for setup details.

## Development Philosophy

**"Simple to run. Simple to use. Simply no bloat."** This is the guiding constraint for
every change, and it means:

- **No frontend framework.** No React, no Vue, no Turbo/Stimulus, no jQuery. Pages are
  server-rendered ERB; interactivity is hand-written DOM manipulation.
- **No Rails.** Sinatra in classic style, with ActiveRecord bolted on for models and
  migrations only.
- **One file of state.** All data lives in a single SQLite file
  (`sqlite/simplee_food.<env>.sqlite3`) so users can back up and restore by copying it.
  No Postgres, no Redis, no background job queue.
- **Minimal dependencies.** Be reluctant to add a gem or npm package. Prefer ~30 lines
  of plain Ruby/JS over a new dependency.
- **One container, no config.** `docker compose up` must be enough. Configuration is
  limited to a couple of env vars plus a `/settings` page backed by the `configs` table.

When adding a feature, the default answer to "should we introduce a new layer/
abstraction/library for this?" is no.

## Coding Style

### Ruby

- **Prettier formats Ruby**, via `@prettier/plugin-ruby` — not RuboCop. This is why you
  see parenthesized multi-line conditional expressions assigned to variables and
  `&&`/`||` wrapped at odd places. Don't hand-fight the formatter; run
  `yarn run lint` and commit what it produces.
- Single-quoted strings, 2-space indent, 80-column target.
- `.prettierignore` exempts `*.erb`, `*.scss`, `Gemfile`, `Rakefile`, `config.ru`,
  `bin/*`, `db/schema.rb`, and `public/*`. Everything under `app/**/*.rb` and
  `spec/**/*.rb` is formatted.
- Comments explain *why*, and are used generously where logic is non-obvious — see the
  pagination math in `app/services/recipe_search_service.rb` or the `dest` redirect
  handling in `app/controllers/auth_controller.rb`. Match that density.

### Service objects

Anything beyond a trivial query lives in `app/services/` and follows one shape:

```ruby
class UserUpdateService
  class UpdateError < StandardError
  end

  def initialize(target, params = {})
    @target = target
    @params = params
  end

  def call
    error!('...') if invalid?
    # ...
  end

  private

  def error!(msg)
    raise UpdateError.new(msg)
  end
end
```

- Constructed with `.new(...)`, invoked with `#call`, one public method.
- Private methods roughly alphabetized; methods that mutate instance state are named
  with a bang (`search!`, `paginate!`, `scope_to_tag!`).
- Errors are raised as a service-local `StandardError` subclass and rescued by the
  controller, which turns them into a flash message or a JSON error body.
- Params are accessed as strings (`@params['page']`), matching Sinatra's `params`.

### Models

Thin `ActiveRecord::Base` subclasses in `app/models/`. Validations and associations
only; logic belongs in a service. Shared behavior comes in as a module from
`app/helpers/` (e.g. `include SlugHelper`). JSON-ish columns (`ingredients`,
`instructions`) are serialized by hand with overridden getters/setters.

### CSS / SCSS

- One SCSS file per view, mirroring the view path, all `@import`ed by
  `app/frontend/stylesheets/index.scss`. Shared partials live in `shared/`.
- BEM-ish naming scoped by page: `.recipes-index__search-input--touched`.
- `stylelint` with `stylelint-config-rational-order` enforces property ordering.

### JavaScript

- Plain ES modules under `app/frontend/js/`, no framework, no transpiler beyond rollup.
- Rollup bundles everything into a single IIFE exposed as the global `SimpleeFood`.
  Handlers are wired up with inline attributes in ERB:
  `onclick="SimpleeFood.onRecipeDelete(event)"`.
- **Every function used from a view must be re-exported from
  `app/frontend/js/index.js`** — it imports from each module and re-exports a flat,
  alphabetized list. Adding a handler without adding it there is the most common
  mistake.
- Prettier config: single quotes, semicolons, no trailing commas, 2-space indent.

## Main Components

### Sinatra (classic style)

`app/app.rb` is the whole application setup: DB connection, `public_folder`, sessions,
then a glob that `require`s every file under `app/{controllers,helpers,models,services}`.
`config.ru` just runs `Sinatra::Application`.

There are **no controller classes**. Files in `app/controllers/` are bare collections of
top-level route blocks:

```ruby
require_relative 'auth_controller'

get '/recipes/:slug', authenticate: :conditionally do
  @recipe = Recipe.find_by_slug(params['slug']&.downcase)
  return(status 404) unless @recipe

  @page_title = truncate_str(@recipe.name)
  erb :'recipes/show'
end
```

Conventions:

- Routes set `@ivars` and `@page_title`, then render with `erb :'dir/view'`.
- Auth is a custom Sinatra `condition` registered in `app/controllers/auth_controller.rb`
  and applied per route as `authenticate: :always` (login required) or
  `authenticate: :conditionally` (required only when the `ENFORCE_AUTH` config row is
  set, enabling a public read-only instance). New routes must declare one of the two.
- Session state is just `session[:user_id]` + `session[:expires_at]`; the `before` filter
  populates `@current_user`.
- Helpers are registered through Sinatra's `helpers do ... end` block
  (`app/helpers/asset_helpers.rb`, `string_helper.rb`); plain mixins for models are
  ordinary modules in the same directory.
- `app/controllers/api/` holds the JSON endpoints that the frontend calls. They
  **render ERB partials and return them as an HTML string inside a JSON body**
  (`{ html: ... }`), which the JS injects into the DOM. That's how search, sort, and
  pagination work without a client-side framework — keep new dynamic features in this
  shape rather than returning data and templating in JS.

### Simple layout

`app/views/layout.erb` is the only layout: meta tags, the hashed CSS/JS asset links,
the Google font, favicons, `<%= yield %>`, and a footer showing `APP_VERSION`.

Views are grouped by route (`views/recipes/`, `views/auth/`, …) with shared partials in
`views/shared/`. Partials are rendered by calling `erb` inline with explicit locals:

```erb
<%= erb(:"recipes/recipe-item", {}, recipes: @recipes, pagination: @pagination) %>
<%= erb(:"shared/nav") %>
```

The same partial is reused by the `api/` endpoints with `{ layout: false }`, so keep
partials self-contained and locals-driven (no reliance on controller `@ivars`).

### Asset management

`rollup.config.js` builds `app/frontend/` into `public/`:

- `js/index.js` → `application-[hash].js` (IIFE, global `SimpleeFood`, uglified in prod)
- `stylesheets/index.scss` → `application-[hash].css` (compressed in prod)
- `images/**/*` → copied to `public/images/`
- a `public/manifest.json` mapping logical names to hashed filenames

`app/helpers/asset_helpers.rb` reads that manifest: `css_asset_path(:application)`,
`js_asset_path(:index)`, `image_asset_path('favicons/favicon.svg')`. SVG icons are
inlined with `svg_icon(:pencil)` and the recipe placeholder is base64'd.

**`public/` is gitignored** — assets are never committed. They're built by
`yarn run build:dev` (watch) locally, `build:prod` in the container's entrypoint, and
`build:test` automatically before feature specs. Note the manifest key quirk documented
in `rollup.config.js`: the CSS entry is keyed `application.css.css`, which
`css_asset_path` works around.

### Specs

RSpec, in `spec/`, split into `models/`, `services/`, and `features/`.

- Every spec file starts with `require 'sinatra_helper'`. That helper (not
  `spec_helper`) deletes and rebuilds the test SQLite DB, loads `app/app.rb`, then loads
  `spec_helper.rb` and everything in `spec/support/`.
- **Feature specs are the primary coverage** for anything user-facing. They're tagged
  `type: :feature, js: true` and drive headless Chrome through Capybara against the real
  Sinatra app, exercising the ERB + JS + API-partial stack end to end. A new user-facing
  feature should come with a feature spec.
- `spec/support/rollup.rb` runs the frontend build once before the suite, but only if
  feature specs are in the run.
- Shared Capybara interactions go in `spec/support/*_helpers.rb` (mixed into
  `FeatureHelpers`) — e.g. `log_in(user)`, `click_next_page`,
  `expect_displayed_recipes_to_be([...])`. Specs read as sequences of those helpers with
  comments spelling out the expected ordering; prefer adding a helper over inlining
  selectors.
- FactoryBot for fixtures, DatabaseCleaner between examples, shoulda-matchers for model
  validations. Screenshots on failure are only saved on CI.
- CI splits the suite: `bundle exec rspec --tag ~type:feature` and
  `--tag type:feature` run as separate jobs.

## Common Commands

```shell
bin/app setup        # one-time: bundle, db:create, db:migrate, db:seed
bin/app backend      # Sinatra on :9292 via rerun (hot reload on *.rb)
bin/app frontend     # rollup --watch
bin/app console      # pry with the app loaded

bundle exec rspec                      # full suite
bundle exec rspec --tag ~type:feature  # skip browser specs (fast)
bundle exec rake db:migrate            # after adding a migration; restart backend

yarn run lint        # stylelint + prettier, both with --fix/--write
```

Dev login is `indra` / `sekrit` (from `db/seeds.rb`). To reset, delete
`sqlite/simplee_food.development.sqlite3` and re-run `bin/app setup`.

## Deployment

Deployment is a Docker image, `abhchand/simplee_food`, run by users via
`docker-compose.yml`. There is no server to deploy to.

**`CHANGELOG.md` drives releases.** The top `## vX.Y.Z` heading is the version, and it's
read in two places: `app/version.rb` parses it at boot to render `APP_VERSION` in the
footer, and `.github/workflows/build.yml` parses it to decide whether to publish. The
release flow is:

1. Tests, browser tests, and lint run on every push/PR.
2. On `main`, CI reads the top version from `CHANGELOG.md`. If a `vX.Y.Z` git tag
   **already exists**, the build stops there.
3. If it doesn't, CI builds the image, pushes it as both `vX.Y.Z` and `latest` to Docker
   Hub, and pushes the git tag.

So **shipping a release means adding a new version heading at the top of
`CHANGELOG.md`** in the same style as existing entries (a bulleted list of
user-visible changes). Merging to `main` without bumping it is a no-op for publishing —
which is the normal case for internal changes.

The image (`Dockerfile`) is `ruby:3.0.0-slim-buster` plus node 18 (installed via nvm),
yarn, and ImageMagick. `entrypoint.sh` runs at container start and handles
create-or-migrate on the DB, creates the initial `admin` / `sekrit` user on a fresh
install (`rake simplee_food:create_initial_user`), builds production assets with
`yarn run build:prod`, then execs `rackup` on port 8080.

Runtime surface, which should stay this small:

- `SIMPLEE_FOOD_APP_PORT` — host port (default `8080`)
- `SIMPLEE_FOOD_SESSION_SECRET` — optional; otherwise `app/session_secret_manager.rb`
  generates and persists one
- `RACK_ENV=production`
- a volume mount for `./sqlite`, which holds the one file that matters

Version pinning is `ruby "3.0.0"` / `.ruby-version`, `.nvmrc` at 18.20.7, and
`package.json` `engines` — the Dockerfile and both CI jobs hardcode these same versions,
so bumping a runtime means updating all of them together.
