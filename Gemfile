source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", ">= 7.0.4.3"

gem "activerecord-import"
gem "bcrypt"
gem "govuk_app_config"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "pagy"
gem "pg"
gem "puma", "~> 6.4"
gem "sentry-rails"
gem "sentry-ruby"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "cssbundling-rails", "~> 1.4"
gem "jsbundling-rails", "~> 1.3"
gem "sprockets", "~> 4.2"
gem "sprockets-rails", "~> 3.4"

group :test do
  gem "database_cleaner-active_record"
  gem "rails-controller-testing"
  gem "simplecov", require: false
  gem "simplecov-json", require: false
end

group :development, :test do
  gem "brakeman", require: false
  gem "capybara"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end
