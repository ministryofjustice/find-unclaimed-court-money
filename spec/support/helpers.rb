module Helpers
  def request_login_as(name, password)
    post admin_login_path, params: { login: { name:, password: } }
  end

  def system_login_as(name, password)
    visit "/admin"
    expect(page).to have_selector("h1", text: "Admin login")

    fill_in "Login name", with: name
    fill_in "Password", with: password
    click_button "Login"
  end

  # Capybara boots a real Puma server the first time a spec switches from
  # rack_test to a browser driver, which can occasionally be slower than the
  # driver's read timeout when this happens partway through a long run.
  # Retrying only this first navigation avoids that cold-start flake without
  # masking a genuine failure later in the journey.
  def visit_with_retry(path, attempts: 3)
    attempts.times do |attempt|
      return visit(path)
    rescue Net::ReadTimeout
      raise if attempt == attempts - 1

      sleep 1
    end
  end
end
