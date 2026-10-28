#!/usr/bin/env ruby
# Temporary CI diagnostic script - prints Selenium Manager's chromedriver
# resolution and full debug logging so we can see why chromedriver exits
# immediately, since that detail doesn't reach RSpec's failure output.
require "selenium-webdriver"

Selenium::WebDriver.logger.level = :debug
Selenium::WebDriver.logger.output = $stdout

options = Selenium::WebDriver::Chrome::Options.new
options.binary = ENV["CHROME_PATH"] if ENV["CHROME_PATH"]
options.add_argument("--headless=new")
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

puts "CHROME_PATH=#{ENV['CHROME_PATH'].inspect}"
puts "Selenium::WebDriver::VERSION=#{Selenium::WebDriver::VERSION}"

# log: :stdout stops chromedriver's own stdout/stderr being redirected to
# /dev/null, which is the default - without this we never see chromedriver's
# actual crash output, only "process exited with status 1".
service = Selenium::WebDriver::Chrome::Service.new(log: :stdout, args: ["--verbose"])

driver = Selenium::WebDriver.for(:chrome, options:, service:)
puts "Launched OK: #{driver.capabilities['browserVersion']}"
driver.quit
