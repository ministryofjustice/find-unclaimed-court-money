RSpec.describe "Login" do
  let!(:user) { create(:user, name: "test_user", password: "mypass") }

  it "allows user to login" do
    get admin_path
    expect(response).to be_successful
    expect(response.body).to include("Admin login")

    post admin_login_path, params: { login: { name: "test_user", password: "mypass" } }
    expect(response).to redirect_to(admin_upload_path)
  end

  it "loads user into session" do
    request_login_as("test_user", "mypass")
    expect(session[:user_id]).to eq user.id
  end

  it "handles invalid login details" do
    post admin_login_path, params: { login: { name: "test_user", password: "" } }
    expect(response.body).to include("There is a problem")
  end

  context "when logged in" do
    before do
      request_login_as("test_user", "mypass")
    end

    it "allows user to logout" do
      delete admin_logout_path
      expect(response).to redirect_to(admin_path)

      expect(session[:user_id]).to be_nil
    end

    it "automatically redirects user away from login page" do
      get admin_path
      expect(response).to redirect_to(admin_upload_path)
    end
  end
end
