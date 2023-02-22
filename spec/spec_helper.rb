ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Helpers
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
end
