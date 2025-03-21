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

  describe "POST /cookies" do
    context "when accepting" do
      it "sets the cookie value to accepted" do
        post "/cookies", params: { consent: "accept" }
        expect(cookies["fum_cookies_consent"]).to eq "accept"
      end

      it "redirects the user back" do
        post "/cookies", params: { consent: "accept" }
        expect(response).to redirect_to("/")
      end
    end

    context "when rejecting" do
      it "sets the cookie value to rejected" do
        post "/cookies", params: { consent: "reject" }
        expect(cookies["fum_cookies_consent"]).to eq "reject"
      end

      it "redirects the user back" do
        post "/cookies", params: { consent: "reject" }
        expect(response).to redirect_to("/")
      end
    end

    context "with invalid value" do
      it "is not found" do
        post "/cookies", params: { consent: "invalid" }
        expect(response).to be_not_found
      end
    end
  end
end
