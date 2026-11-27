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
    search = build(:search, keywords: nil, date_from: nil, date_to: nil, carried_over: nil)
    search.valid?
    assign(:search, search)
    render template: "searches/new", layout: "layouts/application"
    expect(rendered).to have_css("title", text: "Error: Search - Find unclaimed court money", visible: :all)
  end
end
