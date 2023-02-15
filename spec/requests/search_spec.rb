RSpec.describe "Search" do
  it "returns search results" do
    get search_path
    expect(response).to be_successful
    expect(response.body).to include("Search for unclaimed court money")
    expect(response.body).to include("<form")

    get search_results_path, params: { search: { keywords: "test" } }
    expect(response).to be_successful
    expect(response.body).to include("Search results")
  end

  it "downloads results as CSV" do
    get search_results_path("csv"), params: { search: { keywords: "test" } }
    expect(response.content_type).to eq("text/csv; charset=utf-8")
  end

  it "handles invalid search request" do
    get search_results_path, params: { search: { keywords: "" } }
    expect(response).to be_successful
    expect(response.body).to include("There is a problem")
  end
end
