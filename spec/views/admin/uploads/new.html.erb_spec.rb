RSpec.describe "admin/uploads/new.html.erb" do
  it "renders the form for a file upload", :aggregate_failures do
    assign(:upload, build(:upload, file: nil))
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_selector("button", text: "Upload")
  end

  context "when the form is submitted with an invalid file" do
    it "sets focus to the error summary after validation" do
      assign(:upload, build(:upload, file: nil))
      render
      expect(rendered).to have_selector(".div[role='alert'][tabindex='-1']")
    end
  end
end

