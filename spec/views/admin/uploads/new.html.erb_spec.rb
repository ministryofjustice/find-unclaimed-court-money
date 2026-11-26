RSpec.describe "admin/uploads/new.html.erb" do
  it "renders the form for a file upload", :aggregate_failures do
    # rubocop:disable Capybara/RSpec/SpecificMatcher
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_css("form")
    expect(rendered).to have_css("button", text: "Upload")
    # rubocop:enable Capybara/RSpec/SpecificMatcher
  end

  it "displays the page title with error prefix", :aggregate_failures do
    assign(:upload, build(:upload))
    render

    expect(rendered).to have_css("title", text: "Error: Upload CSV - Find unclaimed court money")
  end
end
