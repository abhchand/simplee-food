source "https://rubygems.org"

ruby "3.0.0"

gem "activerecord", "~> 6.0.0"
gem "activesupport", "~> 6.0.0"
gem "image_processing", "~> 1.13"
gem "rake", "~> 13.1.0"
gem "sinatra", "~> 3.1.0"
gem "sinatra-activerecord", "~> 2.0.27"
gem "sinatra-flash", "~> 0.3.0"
gem "sqlite3", "~> 1.7"
gem "webrick", "~> 1.8", ">= 1.8.1"

group :development, :test do
  gem "database_cleaner-active_record", "~> 2.2", require: false
  # Prettier docs suggest to _not_ install `prettier` any more, and directly
  # install the dependencies it depends on. But... it works so far
  # https://github.com/prettier/plugin-ruby#getting-started
  gem "prettier", "~> 3.2", ">= 3.2.2"
  gem "prettier_print", "~> 1.2"
  gem "pry", "~> 0.14.2"
  gem "rerun", "~> 0.11.0"
  gem "rspec", "~> 3.10"
end

group :test do
  gem "capybara", "~> 3.9"
  gem "capybara-screenshot"
  gem "factory_bot", "~> 6.4", ">= 6.4.6", require: false
  gem "selenium-webdriver", "~> 4.26.0"
  gem "shoulda-matchers", "~> 5.3", require: false
end
