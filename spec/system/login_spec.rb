RSpec.describe "Login" do
  before do
    create(:user, name: "test_user", password: "mypassword")
    driven_by(:rack_test)
    Capybara.app_host = "http://admin.example.com"
  end

  after do
    Capybara.app_host = "http://www.example.com"
  end

  it "allows the user to login" do
    system_login_as("test_user", "mypassword")
    expect(page).to have_selector("h1", text: "Upload CSV")
  end

  it "allows the user to logout" do
    system_login_as("test_user", "mypassword")

    visit("/admin/upload")
    click_on("Log out")

    expect(page).to have_selector("h1", text: "Admin login")
  end

  it "does not allow logged out user access to upload page" do
    visit("/admin/upload")
    expect(page).to have_selector("h1", text: "Admin login")
  end

  it "tells the user if there was a problem with login details" do
    system_login_as("test_user", "incorrect")
    expect(page).to have_selector("h2", text: "There is a problem")
  end
end
