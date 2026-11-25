RSpec.describe "admin/uploads/new.html.erb" do
  it "renders the form for a file upload", :aggregate_failures do
    # rubocop:disable Capybara/RSpec/SpecificMatcher
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_css("form")
    expect(rendered).to have_css("button", text: "Upload")
    # rubocop:enable Capybara/RSpec/SpecificMatcher
  end
end
