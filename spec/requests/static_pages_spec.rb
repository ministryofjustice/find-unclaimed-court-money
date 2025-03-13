RSpec.describe "Static pages" do
  it "shows the homepage" do
    get root_path
    expect(response).to be_successful
    expect(response.body).to include("Find unclaimed court money")
    expect(response.body).to include(search_path)
  end

  it "shows the accessibility page" do
    get accessibility_path
    expect(response).to be_successful
    expect(response.body).to include("Accessibility statement for Find unclaimed court money")
  end

  it "shows the cookie page" do
    get cookies_path
    expect(response).to be_successful
    expect(response.body).to include("Request for personal information puts small files")
  end
end
