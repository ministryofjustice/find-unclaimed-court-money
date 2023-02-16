source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

gem "rails", "~> 7.0.4", ">= 7.0.4.2"

gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false
gem "govuk_app_config"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "jbuilder"
gem "pagy"
gem "pg"
gem "puma", "~> 5.0"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "cssbundling-rails", "~> 1.1"
gem "jsbundling-rails", "~> 1.1"
gem "sprockets", "~> 4.2"
gem "sprockets-rails", "~> 3.4"

group :test do
  gem "simplecov", require: false
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "govuk_test"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
end

group :development do
  gem "web-console"
end
