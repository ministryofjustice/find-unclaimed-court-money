RSpec.describe "admin/uploads/complete.html.erb" do
  it "renders results details for the upload", :aggregate_failures do
    assign(:results, { added: 1009, failed: 1, errors: [20] })
    render

    expect(rendered).to have_text("Records added or updated1009")
    expect(rendered).to have_text("Records failed1")
    expect(rendered).to have_text("Lines with errors20")
  end
end
