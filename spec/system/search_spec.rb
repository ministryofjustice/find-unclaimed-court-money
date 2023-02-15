RSpec.describe "Search" do
  before do
    create(:case, case_name: "Test Case")
    driven_by(:selenium_chrome_headless)
  end

  it "lets me search for a case and view its details" do
    # homepage
    visit "/"
    click_link "Start now"

    # Search page
    expect(page).to have_selector("h1", text: "Search for unclaimed court money")
    fill_in "keywords", :with => "test"
    click_button "Search"

    # Search results
    expect(page).to have_selector("h1", text: "Search results")
    expect(page).to have_selector("a", text: "Test Case")
    click_link("Test Case")

    # Case page
    expect(page).to have_selector("h1", text: "Account details")
  end

  it "tells me if there was a problem with my search input" do
    visit "/search"
    click_button "Search"

    expect(page).to have_selector("h2", text: "There is a problem")
    expect(page).to have_selector("a", text: "Keywords can't be blank")
  end
end
