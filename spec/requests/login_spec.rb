RSpec.describe "Login" do
  before do
    create(:user, name: "test_user", password: "mypass")
  end

  it "does not allow access to the login page if not on the admin subdomain" do
    get admin_path
    expect(response.body).not_to include("Admin login")
  end

  context "when on admin subdomain" do
    before { host! "admin.example.com" }

    it "allows user to login" do
      get admin_path
      expect(response).to be_successful
      expect(response.body).to include("Admin login")

      post login_path, params: { login: { name: "test_user", password: "mypass" } }
      expect(response).to redirect_to(upload_path)
    end

    it "handles invalid login details" do
      post login_path, params: { login: { name: "test_user", password: "" } }
      expect(response.body).to include("There is a problem")
    end
  end
end
