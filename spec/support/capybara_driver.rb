Capybara.register_driver :headless_chrome do |app|
  opts = Selenium::WebDriver::Chrome::Options.new
  opts.add_argument('--headless')
  opts.add_argument('--window-size=1440,800')
  opts.add_argument('--no-sandbox')
  opts.add_argument('--disable-dev-shm-usage')
  opts.add_argument('--enable-logging')

  opts.add_preference(:default_content_settings, popups: 0)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts)
end
