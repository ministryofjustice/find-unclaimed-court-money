RSpec.describe "Upload" do
  before do
    create(:user, name: "test_user", password: "mypassword")
    driven_by(:rack_test)
    Capybara.app_host = "http://admin.example.com"
    system_login_as("test_user", "mypassword")
  end

  after do
    Capybara.app_host = "http://www.example.com"
  end

  it "allows a user to upload a file" do
    expect(Case.count).to eq 0

    attach_file "upload[file]", file_fixture("test.csv")
    click_button "Upload"

    expect(page).to have_selector("h1", text: "Upload CSV Complete")
    expect(Case.count).to eq 2
  end
end
