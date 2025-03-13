RSpec.describe "Cookies", type: :request do
  describe "GET /cookies/accept" do
    it "sets the cookie value to accepted" do
      get "/cookies/accept"
      expect(cookies["fum_cookies_consent"]).to eq "accept"
    end

    it "redirects the user back" do
      get "/cookies/accept"
      expect(response).to redirect_to("/")
    end
  end

  describe "GET /cookies/reject" do
    it "sets the cookie value to rejected" do
      get "/cookies/reject"
      expect(cookies["fum_cookies_consent"]).to eq "reject"
    end

    it "redirects the user back" do
      get "/cookies/reject"
      expect(response).to redirect_to("/")
    end
  end
end
