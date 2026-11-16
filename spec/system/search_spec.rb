RSpec.describe "Search" do
  before do
    create(:case, case_name: "Test Case", case_date: "20/06/1967")
  end

  it "lets me search for a case and view its details" do
    # homepage
    visit "/"
    click_link "Start now"

    # Search page
    expect(page).to have_selector("h1", text: "Search for unclaimed court money")
    fill_in "keywords", with: "test"
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

  it "lets me search for a case within a date range" do
    # Search page
    visit "/search"

    fill_in "search_date_from_3i", with: "1"
    fill_in "search_date_from_2i", with: "1"
    fill_in "search_date_from_1i", with: "1967"

    fill_in "search_date_to_3i", with: "31"
    fill_in "search_date_to_2i", with: "12"
    fill_in "search_date_to_1i", with: "1967"

    click_button "Search"

    # Search results
    expect(page).to have_selector("h1", text: "Search results")
    expect(page).to have_selector("a", text: "Test Case")
    click_link("Test Case")

    # Case page
    expect(page).to have_selector("h1", text: "Account details")
  end

  it "lets me search for a case within a date range and tells me if nothing is found" do
    # Search page
    visit "/search"

    fill_in "search_date_from_3i", with: "1"
    fill_in "search_date_from_2i", with: "1"
    fill_in "search_date_from_1i", with: "1967"

    fill_in "search_date_to_3i", with: "10"
    fill_in "search_date_to_2i", with: "2"
    fill_in "search_date_to_1i", with: "1967"

    click_button "Search"

    # Search results
    expect(page).to have_selector("h1", text: "Search results")
    expect(page).to have_selector("p", text: "Nothing found to display.")
  end

  it "lets me search for a case by year carried over" do
    visit "/search"

    fill_in "Search by year carried over", with: "2019"
    click_button "Search"

    expect(page).to have_selector("h1", text: "Search results")
    expect(page).to have_selector("p", text: "Nothing found to display.")
  end

  it "lets me download the search results as a CSV matching the results shown on screen" do
    visit "/search"
    fill_in "keywords", with: "test"
    click_button "Search"

    expect(page).to have_selector("a", text: "Test Case")
    account_number = find("a", text: "Test Case")[:href].split("/").last

    click_link "Download results as CSV"

    expect(page.response_headers["Content-Type"]).to include("text/csv")
    expect(page.body).to include(account_number)
    expect(page.body).to include("Test Case")
  end
end
