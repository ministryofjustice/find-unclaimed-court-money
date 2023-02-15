RSpec.describe "cases/show.html.erb" do
  let(:kase) { create(:case) }

  before do
    assign(:case, kase)
    render
  end

  it "displays the case account number" do
    expect(rendered).to have_text(kase.account_number)
  end

  it "displays the case year carried over" do
    expect(rendered).to have_text(kase.year_carried_over)
  end

  it "displays the case name" do
    expect(rendered).to have_text(kase.case_name)
  end

  it "displays the case date account opened" do
    expect(rendered).to have_text(kase.date_account_opened)
  end

  it "displays the case credit details" do
    expect(rendered).to have_text(kase.credit_details)
  end
end
