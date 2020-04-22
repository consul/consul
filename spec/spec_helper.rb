require "factory_bot_rails"
require "database_cleaner"
require "email_spec"
require "devise"
require "knapsack_pro"

Dir["./spec/models/concerns/*.rb"].each { |f| require f }
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
Dir["./spec/shared/**/*.rb"].sort.each  { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include RequestSpecHelper, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include(CommonActions)
  config.include(ActiveSupport::Testing::TimeHelpers)

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end

    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do |example|
    DatabaseCleaner.strategy = :transaction
    I18n.locale = :en
    Globalize.locale = nil
    Globalize.set_fallbacks_to_all_available_locales
    load Rails.root.join("db", "seeds.rb").to_s
    Setting["feature.user.skip_verification"] = nil
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    unless driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before(:each, type: :feature) do
    Capybara::Webmock.start
  end

  config.after(:suite) do
    Capybara::Webmock.stop
  end

  config.after(:each, :page_driver) do
    page.driver.reset!
  end

  config.before do
    DatabaseCleaner.start
  end

  config.append_after do
    DatabaseCleaner.clean
  end

  config.before(:each, type: :feature) do
    Bullet.start_request
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(0)
  end

  config.after(:each, type: :feature) do
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end

  config.before(:each, :delay_jobs) do
    Delayed::Worker.delay_jobs = true
  end

  config.after(:each, :delay_jobs) do
    Delayed::Worker.delay_jobs = false
  end

  config.before(:each, :with_frozen_time) do
    travel_to Time.current # TODO: use `freeze_time` after migrating to Rails 5.2.
  end

  config.after(:each, :with_frozen_time) do
    travel_back
  end

  config.before(:each, :application_zone_west_of_system_zone) do
    application_zone = ActiveSupport::TimeZone.new("Quito")
    system_zone = ActiveSupport::TimeZone.new("Madrid")

    allow(Time).to receive(:zone).and_return(application_zone)

    system_time_at_application_end_of_day = Date.current.end_of_day.in_time_zone(system_zone)

    allow(Time).to receive(:now).and_return(system_time_at_application_end_of_day)
    allow(Date).to receive(:today).and_return(system_time_at_application_end_of_day.to_date)
  end

  config.before(:each, :with_non_utc_time_zone) do
    application_zone = ActiveSupport::TimeZone.new("Madrid")

    allow(Time).to receive(:zone).and_return(application_zone)
  end

  config.before(:each, :spanish_search) do |example|
    allow(SearchDictionarySelector).to receive(:call).and_return("spanish")
  end

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before(:each) do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?).and_return(true)
  end
end

# Parallel build helper configuration for travis
KnapsackPro::Adapters::RSpecAdapter.bind
