RSpec.describe "Login" do
  let!(:user) { create(:user, name: "test_user", password: "mypass") }

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

    it "loads user into session" do
      login_as("test_user", "mypass")
      expect(session[:user_id]).to eq user.id
    end

    it "handles invalid login details" do
      post login_path, params: { login: { name: "test_user", password: "" } }
      expect(response.body).to include("There is a problem")
    end

    context "when logged in" do
      before do
        login_as("test_user", "mypass")
      end

      it "allows user to logout" do
        delete logout_path
        expect(response).to redirect_to(admin_path)

        expect(session[:user_id]).to be_nil
      end

      it "automatically redirects user away from login page" do
        get admin_path
        expect(response).to redirect_to(upload_path)
      end
    end
  end
end
