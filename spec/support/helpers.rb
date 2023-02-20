module Helpers
  def request_login_as(name, password)
    post login_path, params: { login: { name:, password: } }
  end

  def use_admin_subdomain
    host! "admin.example.com"
  end

  def system_login_as(name, password)
    visit "/"
    expect(page).to have_selector("h1", text: "Admin login")

    fill_in "Login name", with: name
    fill_in "Password", with: password
    click_button "Login"
  end
end
