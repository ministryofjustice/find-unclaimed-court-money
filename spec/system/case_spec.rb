RSpec.describe "Case" do
  let!(:kase) { create(:case, case_name: "Test Case") }

  before do
    driven_by(:rack_test)
    visit "/cases/#{kase.account_number}"
  end

  it "lets me view case details" do
    expect(page).to have_selector("h1", text: "Account details")
    expect(page).to have_text("Test Case")
  end

  it "has a button for printing the page" do
    expect(page).to have_selector("a", text: "Print account details")
  end

  it "lets me view more information about what to do next for case" do
    expect(page).to have_no_link("Find and claim money in an unclaimed court account", href: "https://www.gov.uk/find-unclaimed-court-money")
    find(".govuk-details__summary-text").click
    expect(page).to have_link("Find and claim money in an unclaimed court account", href: "https://www.gov.uk/find-unclaimed-court-money")
  end
end
