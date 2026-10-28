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
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--window-size=1280,1024")
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end
