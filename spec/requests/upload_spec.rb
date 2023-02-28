RSpec.describe "Upload" do
  context "when not logged in" do
    it "redirects if not logged in" do
      get admin_upload_path
      expect(response).to be_redirect
    end
  end

  context "when logged in" do
    before do
      create(:user, name: "test_user", password: "mypass")
      request_login_as("test_user", "mypass")
    end

    it "shows upload page" do
      get admin_upload_path
      expect(response).to be_successful
      expect(response.body).to include("Upload CSV")
    end

    it "uploads a csv file" do
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("Upload CSV Complete")
    end

    it "handles missing file" do
      post admin_upload_path, params: { upload: { file: nil } }
      expect(response.body).to include("There is a problem")
    end
  end
end
