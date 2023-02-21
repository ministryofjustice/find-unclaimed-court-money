RSpec.describe User do
  subject { build(:user) }

  it { is_expected.to be_valid }

  context "when name is not present" do
    subject { build(:user, name: nil) }

    it { is_expected.not_to be_valid }
  end

  context "when name is not unique" do
    subject { build(:user, name: existing_user.name) }

    let(:existing_user) { create(:user) }

    it { is_expected.not_to be_valid }
  end
end
