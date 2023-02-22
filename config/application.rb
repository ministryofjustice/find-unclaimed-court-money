require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FindUnclaimedCourtMoney
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "London"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/govuk/assets")

    config.exceptions_app = routes

    config.allowlisted_ips = %w[81.134.202.29/32 79.152.189.104/32 179.50.12.212/32 188.172.252.34/32 194.33.192.0/25 194.33.193.0/25 194.33.196.0/25 194.33.197.0/25 195.59.75.0/24 201.33.21.5/32 213.121.161.112/28 52.67.148.55/32 54.94.206.111/32 178.248.34.42/32 178.248.34.43/32 178.248.34.44/32 178.248.34.45/32 178.248.34.46/32 178.248.34.47/32 89.32.121.144/32 185.191.249.100/32 2.138.20.8/32]
  end
end
