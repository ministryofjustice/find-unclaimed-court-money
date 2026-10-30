require "capybara_screenshot_diff/rspec"

Capybara::Screenshot::Diff.configure do |screenshot, diff|
  screenshot.window_size = [1280, 1024]
  screenshot.stability_time_limit = 1
  # The app's strict CSP (style-src :self, no nonce) blocks the gem's inline
  # <style> injection used to hide the text caret before capturing.
  screenshot.hide_caret = false
  diff.driver = :chunky_png
  diff.color_distance_limit = 15
  diff.tolerance = 0.01
end

# RECORD_SCREENSHOTS=1 regenerates baselines instead of failing when none
# exist yet. Used by .github/workflows/record-regression-baselines.yml,
# which runs on the same ubuntu-latest/Chrome combination as CI so captured
# baselines don't drift from a developer's local OS/font rendering.
Capybara::Screenshot::Diff.fail_if_new = false if ENV["RECORD_SCREENSHOTS"]

Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  # Pin the exact Chrome binary .github/workflows/{test,record-regression-baselines}.yml
  # installed via browser-actions/setup-chrome, rather than relying on
  # whichever Chrome (if any) happens to be preinstalled on the runner -
  # that mismatch is what caused Chrome to fail to launch at all. Not set
  # when running locally, where Selenium Manager finds the system Chrome.
  options.binary = ENV["CHROME_PATH"] if ENV["CHROME_PATH"].present?
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  # GitHub Actions runners give Chrome a tiny /dev/shm by default, which
  # crashes the browser process outright ("unexpectedly closed with status
  # 1") rather than producing a usable error - this makes Chrome fall back
  # to /tmp for shared memory instead.
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1280,1024")

  # chromedriver crashing on launch surfaces to RSpec as a blank
  # Selenium::WebDriver::Error::WebDriverError ("process unexpectedly closed
  # with status 1") with no indication of *why* - chromedriver's own
  # stdout/stderr is swallowed by default. Capture it with verbose logging
  # in CI so the next failure shows the real reason instead of just the exit
  # status.
  service = if ENV["CI"].present?
    Selenium::WebDriver::Chrome::Service.new(log: :stdout, args: ["--verbose"])
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:, service:)
end

# capybara_screenshot_diff's `resize_window_if_needed` before-hook (and
# Capybara's own RSpec integration, both registered as unfiltered
# `config.before` hooks that run ahead of our `driven_by` call below in
# spec_helper.rb) resolve the browser via `Capybara.javascript_driver`,
# which defaults to :selenium (Firefox) - that launches and leaves a whole
# second, unused Firefox session running alongside the Chrome one for every
# :js example, wasting resources and - under CI's tight memory - plausibly
# contributing to chromedriver's "process unexpectedly closed" crashes.
Capybara.javascript_driver = :chrome_headless
