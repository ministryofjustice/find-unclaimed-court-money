RSpec.describe "admin/uploads/new.html.erb" do
  it "renders the form for a file upload", :aggregate_failures do
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_selector("button", text: "Upload")
  end

  it "renders the form with a log out link", :aggregate_failures do
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_link("Log out", class: "govuk-link govuk-link--text-colour")
  end
end
