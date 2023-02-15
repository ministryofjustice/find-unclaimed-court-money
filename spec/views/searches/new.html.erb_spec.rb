RSpec.describe "searches/new.html.erb" do
  it "renders the form for a new search", :aggregate_failures do
    assign(:search, build(:search))
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_selector("button", text: "Search")
  end
end
