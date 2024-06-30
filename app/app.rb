require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'active_support'
require 'fastimage'

require 'pathname'

require_relative 'session_secret_manager'

ENV['RACK_ENV'] ||= 'development'

APP_ROOT = Pathname.new(File.expand_path('..', __dir__))
SQLITE_FILE = ENV['SQLITE_FILE_NAME'] || "app.#{ENV['RACK_ENV']}.sqlite3"

## Application Configuration

set :database,
    { adapter: 'sqlite3', database: APP_ROOT.join('sqlite', SQLITE_FILE) }

set :public_folder, APP_ROOT.join('public')

enable :sessions
set :session_secret, SessionSecretManager.fetch_or_create!

set :strict_paths, false

Time.zone = 'UTC'

# Application Resources
%w[controllers helpers models services].each do |type|
  glob = APP_ROOT.join('app', type, '**', '*.rb')
  Dir[glob].each { |file| require file }
end
