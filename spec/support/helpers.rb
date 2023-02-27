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
end
