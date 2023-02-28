RSpec.describe "admin/uploads/new.html.erb" do
  it "renders the form for a file upload", :aggregate_failures do
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_selector("button", text: "Upload")
  end
end
