ENV["RAILS_ENV"] ||= "test"
if ENV["TRAVIS"]
  require "coveralls"
  Coveralls.wear!("rails")
end
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "spec_helper"
require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Rails.application.load_tasks if Rake::Task.tasks.empty?

include Warden::Test::Helpers
Warden.test_mode!

ActiveRecord::Migration.maintain_test_schema!

# Monkey patch from https://github.com/rails/rails/pull/32293
# Remove when we upgrade to Rails 5.2
require "action_dispatch/system_testing/test_helpers/setup_and_teardown"
module ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
  def after_teardown
    take_failed_screenshot
    Capybara.reset_sessions!
  ensure
    super
  end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.after do
    Warden.test_reset!
  end
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      args: %W[headless no-sandbox window-size=1200,600 proxy-server=127.0.0.1:#{Capybara::Webmock.port_number}]
    }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.exact = true

OmniAuth.config.test_mode = true

def with_subdomain(subdomain, &block)
  Capybara.app_host = "http://#{subdomain}.lvh.me"
  block.call
  Capybara.app_host = Capybara.default_host
end
