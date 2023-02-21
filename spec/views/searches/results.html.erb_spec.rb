RSpec.describe "searches/results.html.erb" do
  let(:kase) { create(:case) }

  it "renders a CSV button" do
    assign(:cases, [kase])
    render

    expect(rendered).to have_selector("a", text: "CSV")
  end

  it "renders a table of results", :aggregate_failures do
    assign(:cases, [kase])
    render

    expect(rendered).to have_text(kase.account_number)
    expect(rendered).to have_selector("a", text: kase.case_name)
    expect(rendered).to have_text(kase.date_account_opened)
  end
end
