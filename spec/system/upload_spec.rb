RSpec.describe "Upload" do
  before do
    create(:user, name: "test_user", password: "mypassword")
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

  it "shows a summary with no failures or errors for a fully valid file", :aggregate_failures do
    attach_file "upload[file]", file_fixture("test.csv")
    click_button "Upload"

    expect(page).to have_selector("h1", text: "Upload CSV Complete")
    expect(page).to have_text("Records added or updated2")
    expect(page).to have_text("Records failed0")
  end

  it "reports failed records and the affected line numbers for a file with errors", :aggregate_failures do
    attach_file "upload[file]", file_fixture("with_errors.csv")
    click_button "Upload"

    expect(page).to have_selector("h1", text: "Upload CSV Complete")
    expect(page).to have_text("Records failed1")
    expect(page).to have_text("Lines with errors4")
  end

  it "returns to the upload page via the Back link and lets the user log out" do
    attach_file "upload[file]", file_fixture("test.csv")
    click_button "Upload"

    click_on "Back"
    expect(page).to have_selector("h1", text: "Upload CSV")

    click_on "Log out"
    expect(page).to have_selector("h1", text: "Admin login")
  end
end
