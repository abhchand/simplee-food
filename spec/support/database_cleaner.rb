require "database_cleaner/active_record"

RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.clean_with(:deletion) }

  config.before(:each) { DatabaseCleaner.strategy = :transaction }

  config.before(:each, js: true) { DatabaseCleaner.strategy = :deletion }

  config.before(:each) { DatabaseCleaner.start }

  config.after(:each) { DatabaseCleaner.clean }
end
