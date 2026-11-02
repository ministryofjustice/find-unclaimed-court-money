RSpec.describe "FUM regression journey", :js do
  context "with the public search journey" do
    # Fixed, rather than factory-sequenced: this case name is rendered on
    # pages under screenshot comparison, and a changing value would shift
    # text wrapping and cause false-positive visual regression failures.
    before do
      create(:case, case_name: "Regression Test Case", case_date: Date.new(2019, 6, 20), year_carried_over: "2019")
    end

    it "lets a visitor start, search, download results as CSV, and view case details", :aggregate_failures do
      visit_with_retry "/"
      click_link "Start now"

      expect(page).to have_selector("h1", text: "Search for unclaimed court money")
      expect(page).to match_screenshot("regression/search_page")

      fill_in "keywords", with: "Regression"
      click_button "Search"

      expect(page).to have_selector("h1", text: "Search results")
      expect(page).to have_link("Regression Test Case")
      expect(page).to have_link("Download results as CSV")
      expect(page).to match_screenshot("regression/search_results_page")

      click_link "Regression Test Case"

      expect(page).to have_selector("h1", text: "Account details")
      expect(page).to have_text("Regression Test Case")
      expect(page).to have_link("Print account details")
      expect(page).to match_screenshot("regression/case_details_page")
    end
  end

  context "with the admin upload journey" do
    before do
      create(:user, name: "regression_test", password: "regressionpass")
    end

    it "lets an admin log in, upload a CSV, see the summary, and log out", :aggregate_failures do
      visit_with_retry "/admin"

      expect(page).to have_selector("h1", text: "Admin login")
      expect(page).to match_screenshot("regression/admin_login_page")

      fill_in "Login name", with: "regression_test"
      fill_in "Password", with: "regressionpass"
      click_button "Login"

      expect(page).to have_selector("h1", text: "Upload CSV")

      attach_file "upload[file]", Rails.root.join("spec/fixtures/files/test.csv")
      click_button "Upload"

      expect(page).to have_selector("h1", text: "Upload CSV Complete")
      expect(page).to have_text("Records failed 0")
      expect(page).to match_screenshot("regression/admin_upload_complete_page")

      click_on "Back"
      expect(page).to have_selector("h1", text: "Upload CSV")

      click_on "Log out"
      expect(page).to have_selector("h1", text: "Admin login")
    end
  end
end
