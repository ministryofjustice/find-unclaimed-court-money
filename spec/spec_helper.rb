ENV["RAILS_ENV"] ||= "test"

require "simplecov"
require "simplecov-json"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
])
SimpleCov.start "rails"

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

require "database_cleaner/active_record"

RSpec.configure do |config|
  config.include Helpers
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    # :js specs run the app in a real Selenium/headless-Chrome process against
    # a separate DB connection, which can't see data created inside an
    # uncommitted :transaction - it needs :truncation so factory-created rows
    # are actually committed and visible to that other connection.
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.cleaning { example.run }
  end

  config.before(type: :system) do |example|
    driven_by(example.metadata[:js] ? :chrome_headless : :rack_test)
  end
end
