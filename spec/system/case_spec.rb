RSpec.describe "Case" do
  let!(:kase) { create(:case, case_name: "Test Case") }

  before do
    driven_by(:selenium_chrome_headless)
    visit "/cases/#{kase.id}"
  end

  it "lets me view case details" do
    expect(page).to have_selector("h1", text: "Account details")
    expect(page).to have_text(kase.case_name)
  end

  it "lets me view more information about what to do next for case" do
    expect(page).not_to have_selector(".govuk-heading-s:first-of-type")
    find('.govuk-details__summary-text').click
    expect(page).to have_selector(".govuk-heading-s:first-of-type")
  end
end
