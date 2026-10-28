namespace :regression do
  desc "Smoke-test the public search journey (start -> search -> case details) and, if admin " \
       "credentials are given, the admin CSV upload journey (login -> upload -> summary -> log " \
       "out) against a deployed FUM environment. Does not touch this app's local Rails " \
       "environment or database. Prompts interactively (press Enter to accept the default " \
       "shown, where there is one) for anything not already set via env var: FUM_URL " \
       "(required), FUM_BASIC_AUTH_USER / FUM_BASIC_AUTH_PASS (if the environment is behind " \
       "Basic Auth), FUM_SEARCH_KEYWORD, FUM_ADMIN_USER / FUM_ADMIN_PASS (skips the admin " \
       "journey if left blank), FUM_UPLOAD_FILE (path to a local sample CSV, skips the upload " \
       "step if left blank), FUM_HEADLESS=true (defaults to false, so you can watch it run). " \
       "Never commit real values for these. Pass FUM_DEFAULT=true to skip the 'use defaults?' " \
       "prompt and answer yes automatically - Rake treats --default as its own CLI flag and " \
       "will reject it, so it can't be passed that way."
  # rubocop:disable Rails/RakeEnvironment -- deliberately standalone, doesn't touch this app's Rails env/DB
  task :live_staging_check do
    require "capybara"
    require "selenium-webdriver"
    require "uri"
    require "io/console"
    require "fileutils"

    use_defaults = %w[true 1 yes y].include?(ENV["FUM_DEFAULT"].to_s.downcase)
    if !use_defaults && $stdin.tty?
      print "Use default values for everything except the environment URL? [Y/n]: "
      answer = $stdin.gets&.chomp
      use_defaults = answer.blank? || !answer.strip.downcase.start_with?("n")
    end

    # Falls back to an interactive prompt (masked for `secret`, Enter accepts the
    # default shown) only when the env var is unset and we have a real terminal.
    # Fields with an actual default value are skipped entirely (silently using
    # it) when `use_defaults` was accepted above - fields with no default (e.g.
    # Basic Auth, admin credentials) still get asked, since there's nothing
    # safe to fall back to.
    ask = lambda do |env_name, label, default: nil, secret: false, required: false|
      env_value = ENV[env_name]
      next env_value if env_value.present?
      next default if use_defaults && !required && !default.nil?
      next default unless $stdin.tty?

      default_hint =
        if default
          " [#{secret ? 'hidden' : default}]"
        end
      print "#{label}#{default_hint}: "
      input = secret ? $stdin.noecho(&:gets) : $stdin.gets
      puts if secret
      input&.chomp.presence || default
    end

    base_url = ask.call("FUM_URL", "Environment URL", required: true) ||
      abort("Set FUM_URL, e.g. https://staging-find-unclaimed-court-money.apps.live.cloud-platform.service.justice.gov.uk")
    basic_auth_user = ask.call("FUM_BASIC_AUTH_USER", "Basic Auth username (blank if none)")
    basic_auth_pass = ask.call("FUM_BASIC_AUTH_PASS", "Basic Auth password (blank if none)", secret: true)
    search_keyword = ask.call("FUM_SEARCH_KEYWORD", "Keyword to search for", default: "smith")
    admin_user = ask.call("FUM_ADMIN_USER", "Admin login name (blank to skip the admin journey)")
    admin_pass = ask.call("FUM_ADMIN_PASS", "Admin password", secret: true) if admin_user.present?
    upload_file = ask.call("FUM_UPLOAD_FILE", "Path to a local sample CSV (blank to skip the upload step)") if admin_user.present?
    headless = ask.call("FUM_HEADLESS", "Run headless? (true/false)", default: "false") == "true"

    if upload_file.present? && !File.exist?(upload_file)
      abort("FUM_UPLOAD_FILE #{upload_file} does not exist")
    end

    uri = URI.parse(base_url)
    uri.user = basic_auth_user if basic_auth_user
    uri.password = basic_auth_pass if basic_auth_pass
    app_host = uri.to_s

    Capybara.register_driver :regression_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      if headless
        options.add_argument("--headless=new")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
      end
      options.add_argument("--window-size=1280,1024")
      Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
    end

    Capybara.app_host = app_host
    Capybara.run_server = false
    Capybara.default_max_wait_time = 10

    session = nil

    begin
      puts "== FUM live regression check =="
      puts "Target: #{base_url}"
      puts "Search keyword: #{search_keyword}"
      puts

      # Staging can sleep when idle or occasionally serve a blank response, so
      # the first load can fail - retry a few times with a fresh browser tab
      # and a longer wait rather than failing the whole run on that.
      max_attempts = 3
      attempt = 0
      begin
        attempt += 1
        session&.driver&.quit
        session = Capybara::Session.new(:regression_chrome)
        Capybara.using_wait_time(attempt == 1 ? 10 : 30) do
          session.visit("/")
          session.click_on("Start now")
        end
      rescue Capybara::ElementNotFound
        raise if attempt >= max_attempts

        puts "Start page didn't load (attempt #{attempt}/#{max_attempts}) - retrying with a fresh tab..."
        sleep 5
        retry
      end

      raise "FAIL: did not reach the search page" unless session.has_selector?("h1", text: "Search for unclaimed court money")

      puts "Start page -> search page: OK"

      session.fill_in("keywords", with: search_keyword)
      session.click_button("Search")

      raise "FAIL: did not reach the search results page" unless session.has_selector?("h1", text: "Search results")

      puts "Search results page: OK"

      if session.has_content?("Nothing found to display.")
        puts "No results for '#{search_keyword}' - skipping CSV/case-detail checks. Try a different FUM_SEARCH_KEYWORD."
      else
        raise "FAIL: no 'Download results as CSV' link on the results page" unless session.has_link?("Download results as CSV")

        puts "'Download results as CSV' link present: OK"

        case_link = session.first(:link, href: %r{/cases/})
        raise "FAIL: no case link found in the results table" unless case_link

        case_name = case_link.text
        case_link.click

        raise "FAIL: did not reach the case details page" unless session.has_selector?("h1", text: "Account details")
        raise "FAIL: case details page is missing the 'Print account details' link" unless session.has_link?("Print account details")

        puts "Case details page for '#{case_name}': OK"
      end

      puts

      if admin_user.blank?
        puts "FUM_ADMIN_USER not set - skipping the admin journey."
      else
        puts "== Admin journey =="

        session.visit("/admin")
        raise "FAIL: did not reach the admin login page" unless session.has_selector?("h1", text: "Admin login")

        session.fill_in("Login name", with: admin_user)
        session.fill_in("Password", with: admin_pass)
        session.click_button("Login")

        raise "FAIL: admin login did not succeed" unless session.has_selector?("h1", text: "Upload CSV")

        puts "Admin login: OK"

        if upload_file.blank?
          puts "FUM_UPLOAD_FILE not set - skipping the CSV upload step."
        else
          session.attach_file("upload[file]", File.expand_path(upload_file))
          session.click_button("Upload")

          raise "FAIL: did not reach the 'Upload CSV Complete' page" unless session.has_selector?("h1", text: "Upload CSV Complete")

          summary = session.find(".govuk-summary-list").text
          puts "Upload summary:"
          puts summary.split("\n").map { |line| "  #{line}" }.join("\n")

          if summary.match?(/Records failed\s+[1-9]/)
            puts "WARNING: upload reported failed records - check the summary above"
          else
            puts "Upload completed with no failed records: OK"
          end
        end

        session.click_on("Back")
        session.click_on("Log out")

        raise "FAIL: log out did not return to the admin login page" unless session.has_selector?("h1", text: "Admin login")

        puts "Log out: OK"
      end

      puts
      puts "FUM live regression check passed."
    rescue StandardError => e
      puts
      puts "FAILED: #{e.class}: #{e.message}"
      if session
        puts "Current URL: #{session.current_url}"
        timestamp = Time.now.strftime("%Y%m%d%H%M%S") # rubocop:disable Rails/TimeZone -- local filename timestamp, Rails.application isn't initialized in this standalone task
        FileUtils.mkdir_p("tmp")
        screenshot_path = File.join("tmp", "regression_failure_#{timestamp}.png")
        html_path = File.join("tmp", "regression_failure_#{timestamp}.html")
        session.save_screenshot(screenshot_path)
        File.write(html_path, session.html)
        puts "Screenshot saved to #{screenshot_path}"
        puts "Page HTML saved to #{html_path}"
      end
      raise
    ensure
      session&.driver&.quit
    end
  end
  # rubocop:enable Rails/RakeEnvironment
end
