RSpec.describe "Case" do
  let!(:kase) { create(:case, case_name: "Test Case") }

  before do
    visit "/cases/#{kase.account_number}"
  end

  it "lets me view case details" do
    expect(page).to have_selector("h1", text: "Account details")
    expect(page).to have_text("Test Case")
  end

  it "has a button for printing the page" do
    expect(page).to have_selector("a", text: "Print account details")
  end

  it "lets me view more information about preparing the claim" do
    expect(page).to have_no_link("Get information to prepare your claim", href: "https://www.gov.uk/find-unclaimed-court-money#get-information-to-prepare-your-claim")
    find(".govuk-details__summary-text").click
    expect(page).to have_link("Get information to prepare your claim", href: "https://www.gov.uk/find-unclaimed-court-money#get-information-to-prepare-your-claim")
  end

  it "lets me view more information about claiming within 12 months of the last claim date" do
    expect(page).to have_no_link("claiming 12 months or less before the last claim date", href: "https://www.gov.uk/find-unclaimed-court-money#if-youre-claiming-within-12-months-of-the-last-claim-date")
    find(".govuk-details__summary-text").click
    expect(page).to have_link("claiming 12 months or less before the last claim date", href: "https://www.gov.uk/find-unclaimed-court-money#if-youre-claiming-within-12-months-of-the-last-claim-date")
  end
end
