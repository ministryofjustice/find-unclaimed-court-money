RSpec.describe PingController, type: :controller do
  describe "#index" do
    it "returns a minimal JSON status with no build or infrastructure detail" do
      get :index
      expect(JSON.parse(response.body)).to eq("status" => "ok")
    end
  end

  describe "#deploy_info" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("DEPLOY_DASHBOARD_SHARED_SECRET", nil).and_return("test-secret")
    end

    context "with a valid shared secret" do
      before { request.headers["X-Deploy-Dashboard-Secret"] = "test-secret" }

      it "returns JSON with app information" do
        allow(Deployment).to receive(:info).and_return(foo: "bar")

        get :deploy_info

        expect(JSON.parse(response.body)).to eq("foo" => "bar")
      end
    end

    context "with an invalid shared secret" do
      before { request.headers["X-Deploy-Dashboard-Secret"] = "wrong-secret" }

      it "returns unauthorized" do
        get :deploy_info

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "without a shared secret header" do
      it "returns unauthorized" do
        get :deploy_info

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
