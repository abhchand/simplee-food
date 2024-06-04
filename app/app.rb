require "dotenv/load"
require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "active_support"

require "pathname"

ENV['RACK_ENV'] ||= 'development'

APP_ROOT = Pathname.new(File.expand_path("..", __dir__))
SQLITE_FILE = ENV["SQLITE_FILE_NAME"] || "app.#{ENV['RACK_ENV']}.sqlite3"

## Application Configuration

set :database, { adapter: "sqlite3", database: APP_ROOT.join('sqlite', SQLITE_FILE) }

set :public_folder, APP_ROOT.join('public')

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET')

Time.zone = "UTC"

# Application Resources
%w[controllers helpers models services].each do |type|
  glob = APP_ROOT.join("app", type, "**", "*.rb")
  Dir[glob].each { |file| require file }
end
