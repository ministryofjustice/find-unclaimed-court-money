RSpec.describe "searches/results.csv.erb" do
  let(:kase) { create(:case) }

  it "renders a table of results", :aggregate_failures do
    assign(:cases, [kase])
    render

    expect(rendered).to have_text(kase.account_number)
    expect(rendered).to have_text(kase.case_name)
    expect(rendered).to have_text(kase.credit_details)
    expect(rendered).to have_text(kase.date_account_opened)
    expect(rendered).to have_text(kase.year_carried_over)
    expect(rendered).to have_text(kase.initial_dormancy)
    expect(rendered).to have_text(kase.last_claim_date)
    expect(rendered).to have_text(case_url(kase.account_number))
  end
end
