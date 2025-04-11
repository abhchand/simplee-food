require 'capybara/rspec'
require 'selenium/webdriver'
require 'capybara-screenshot/rspec'

require ROOT.join('app', 'app.rb')

Capybara.app = Sinatra::Application
Capybara.server = :webrick

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  config.javascript_driver = :headless_chrome
  config.default_max_wait_time = 5
end

RSpec.configure { |config| config.include FeatureHelpers, type: :feature }

#
# Screenshot configuration
#

# Control where capybara saves screenshots
# Capybara::Screenshot uses `Capybara.save_path` under the hood
Capybara.save_path =
  (
    if ENV['RUNNING_ON_CI_SERVER']
      '/tmp/capybara-screenshots'
    else
      ROOT.join('tmp', 'capybara-screenshots')
    end
  )

# Only capture screenshots when running the CI build
Capybara::Screenshot.autosave_on_failure = ENV['RUNNING_ON_CI_SERVER'].present?

# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run

# Override the default screenshot filename to inject the test name
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.description.gsub(' ', '-').gsub(%r{^.*/spec/}, '')}"
end

# By default `capybara-screenshot` doesn't know how to render a screenshot for
# the `:headless_chrome` driver. Register a custom driver
Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end
