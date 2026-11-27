RSpec.describe "admin/uploads/new.html.erb" do
  it "renders the form for a file upload", :aggregate_failures do
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_css("form")
    expect(rendered).to have_button("Upload")
  end

  it "displays the page title with error prefix", :aggregate_failures do
    upload = build(:upload, file: nil)
    upload.valid?
    assign(:upload, upload)
    render template: "admin/uploads/new", layout: "layouts/application"

    expect(rendered).to have_css("title", text: "Error: Upload CSV - Find unclaimed court money", visible: :all)
  end
end
