source "https://rubygems.org"

ruby "3.4.13"

gem "activerecord", "~> 8.1.0"
gem "activesupport", "~> 8.1.0"
gem "image_processing", "~> 1.13"
gem "json-ld", "~> 3.3", ">= 3.3.2"
gem "nokogiri", "~> 1.19.7"
gem "rake", "~> 13.1.0"
gem "sinatra", "~> 3.1.0"
gem "sinatra-activerecord", "~> 2.0.28"
gem "sinatra-flash", "~> 0.3.0"
gem "sqlite3", "~> 2.10.2"
gem "webrick", "~> 1.8", ">= 1.8.1"

# json 3.x removed `JSON.fast_generate`, which the (unmaintained) prettier Ruby
# plugin used by `yarn run lint` still calls. Remove once that plugin is replaced.
gem "json", "< 3"

group :development, :test do
  gem "database_cleaner-active_record", "~> 2.2", require: false
  # Prettier docs suggest to _not_ install `prettier` any more, and directly
  # install the dependencies it depends on. But... it works so far
  # https://github.com/prettier/plugin-ruby#getting-started
  gem "prettier", "~> 3.2", ">= 3.2.2"
  gem "prettier_print", "~> 1.2"
  gem "pry", "~> 0.14.2"
  gem "rerun", "~> 0.14.0"
  gem "rspec", "~> 3.10"
end

group :test do
  gem "capybara", "~> 3.9"
  gem "capybara-screenshot"
  gem "factory_bot", "~> 6.4", ">= 6.4.6", require: false
  gem "selenium-webdriver", "~> 4.26.0"
  gem "shoulda-matchers", "~> 5.3", require: false
end
