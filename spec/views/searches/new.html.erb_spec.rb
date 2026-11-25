RSpec.describe "searches/new.html.erb" do
  it "renders the form for a new search", :aggregate_failures do
    # rubocop:disable Capybara/RSpec/SpecificMatcher
    assign(:search, build(:search))
    render

    expect(rendered).to have_css("form")
    expect(rendered).to have_css("button", text: "Search")
    # rubocop:enable Capybara/RSpec/SpecificMatcher
  end
end
