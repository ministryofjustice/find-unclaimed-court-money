RSpec.describe "View case" do
  let(:kase) { create(:case) }

  it "returns details of case" do
    get case_path(kase.account_number)
    expect(response).to be_successful
    expect(response.body).to include("Account details")
    expect(response.body).to include(kase.account_number)
    expect(response.body).to include("What happens next")
  end
end
