require "fileutils"
require "pathname"

ENV["RACK_ENV"] ||= "test"
ROOT = Pathname.new(File.expand_path("..", __dir__))

# Re-create the DB
TEST_SQLITE_FILE = ROOT.join("sqlite", "simplee_food.test.sqlite3")
FileUtils.rm(TEST_SQLITE_FILE) if File.exist?(TEST_SQLITE_FILE)
Dir.chdir(ROOT) do
  %x{bundle exec rake db:create}
  %x{bundle exec rake db:migrate}
end

# Load the application
require File.expand_path("../app/app", __dir__)

# Load RSpec content
require_relative "spec_helper"
Dir[ROOT.join("spec/support/*.rb")].each { |file| require file }
