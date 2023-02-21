RSpec.describe Case do
  subject { create(:case) }

  let(:case_2020) { create(:case, case_date: Date.new(2020, 1, 1)) }
  let(:case_2021) { create(:case, case_date: Date.new(2021, 1, 1)) }
  let(:case_2022) { create(:case, case_date: Date.new(2022, 1, 1)) }

  it { is_expected.to be_valid }

  context "when account_number is not unique" do
    subject { build(:case, account_number: "abc") }

    before { create(:case, account_number: "abc") }

    it { is_expected.not_to be_valid }
  end

  describe ".from_date" do
    before do
      case_2020
      case_2021
      case_2022
    end

    it "only returns cases dated on or after the provided date" do
      expect(described_class.from_date(Date.new(2021, 1, 1))).to match_array [case_2021, case_2022]
    end
  end

  describe ".to_date" do
    before do
      case_2020
      case_2021
      case_2022
    end

    it "only returns cases dated on or before the provided date" do
      expect(described_class.to_date(Date.new(2021, 1, 1))).to match_array [case_2020, case_2021]
    end
  end

  describe ".for_term" do
    let!(:case_chicken) { create(:case, case_name: "contains the keyword ChickeN that we are looking for") }
    let!(:case_turkey) { create(:case, credit_details: "contains the keyword TurkeY that we are looking for") }
    let!(:case_goose) { create(:case, account_number: "contains the keyword GoosE that we are looking for") }

    it "finds cases with the keyword in case_name" do
      expect(described_class.for_term("chiCkeN")).to match_array [case_chicken]
    end

    it "finds cases with the keyword in credit_details" do
      expect(described_class.for_term("turKeY")).to match_array [case_turkey]
    end

    it "finds cases with the keyword in account_number" do
      expect(described_class.for_term("gOOse")).to match_array [case_goose]
    end
  end
end
