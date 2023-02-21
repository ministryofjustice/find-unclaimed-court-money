RSpec.describe Login do
  subject { build(:login) }

  let(:user) { create(:user, password: "mypassword") }

  context "when attributes match a user" do
    subject { build(:login, name: user.name, password: "mypassword") }

    it { is_expected.to be_valid }
  end

  context "when name is missing" do
    subject { build(:login, password: "mypassword") }

    it { is_expected.not_to be_valid }
  end

  context "when password is missing" do
    subject { build(:login, name: user.name) }

    it { is_expected.not_to be_valid }
  end

  context "when attributes do not match a user" do
    subject { build(:login, name: user.name, password: "incorrectpassword") }

    it { is_expected.not_to be_valid }
  end
end
