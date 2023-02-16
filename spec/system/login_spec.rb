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
    visit "/"
    expect(page).to have_selector("h1", text: "Admin login")

    fill_in "Login name", with: "test_user"
    fill_in "Password", with: "mypassword"
    click_button "Login"

    expect(page).to have_selector("h1", text: "Upload CSV")
  end

  it "tells the user if there was a problem with login details" do
    visit "/"
    expect(page).to have_selector("h1", text: "Admin login")

    fill_in "Login name", with: "test_user"
    fill_in "Password", with: "incorrect"
    click_button "Login"

    expect(page).to have_selector("h2", text: "There is a problem")
  end
end
