RSpec.describe "cookies", type: :system do
  context "when first arriving on the site" do
    it "shows cookies banner" do
      visit "/"
      expect(page).to have_text "Cookies on Find unclaimed court money"
    end

    context "when accepting cookies" do
      it "shows confirmation of choice" do
        visit "/"
        click_link("Accept analytics cookies")
        expect(page).to have_text "You've accepted analytics cookies."
      end

      it "keeps the user on the same page" do
        visit "/search"
        click_link("Accept analytics cookies")
        expect(page).to have_text "Search for unclaimed court money"
      end
    end

    context "when rejecting cookies" do
      it "shows confirmation of choice" do
        visit "/"
        click_link("Reject analytics cookies")
        expect(page).to have_text "You've rejected analytics cookies."
      end

      it "keeps the user on the same page" do
        visit "/search"
        click_link("Reject analytics cookies")
        expect(page).to have_text "Search for unclaimed court money"
      end
    end
  end

  context "when returning to the site with cookie value set" do
    before do
      visit "/"
      click_link("Accept analytics cookies")
    end

    it "does not show cookie banner" do
      # rubocop:disable Capybara/RSpec/NegationMatcherAfterVisit
      visit "/"
      expect(page).to have_no_text "Cookies on Find unclaimed court money"
      # rubocop:enable Capybara/RSpec/NegationMatcherAfterVisit
    end
  end
end
