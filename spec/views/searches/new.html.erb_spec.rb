RSpec.describe "searches/new.html.erb" do
  it "renders the form for a new search", :aggregate_failures do
    # rubocop:disable Capybara/RSpec/SpecificMatcher
    assign(:search, build(:search))
    render

    expect(rendered).to have_css("form")
    expect(rendered).to have_css("button", text: "Search")
    # rubocop:enable Capybara/RSpec/SpecificMatcher
  end

  it "displays the page title with error prefix", :aggregate_failures do
    assign(:search, build(:search))
    render

    expect(rendered).to have_css("title", text: "Error: Search - Find unclaimed court money")
    # rubocop:enable Capybara/RSpec/SpecificMatcher
  end
end
