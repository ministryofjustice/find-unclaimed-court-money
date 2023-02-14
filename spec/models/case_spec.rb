RSpec.describe Case, type: :model do
  let(:case_2020) { create(:case, case_date: Date.new(2020, 01, 01)) }
  let(:case_2021) { create(:case, case_date: Date.new(2021, 01, 01)) }
  let(:case_2022) { create(:case, case_date: Date.new(2022, 01, 01)) }

  describe "scopes" do
    describe ".from_date" do
      before do
        case_2020
        case_2021
        case_2022
      end

      it "only returns cases dated on or after the provided date" do
        expect(Case.from_date(Date.new(2021, 1, 1))).to match_array [case_2021, case_2022]
      end
    end

    describe ".to_date" do
      before do
        case_2020
        case_2021
        case_2022
      end

      it "only returns cases dated on or before the provided date" do
        expect(Case.to_date(Date.new(2021, 1, 1))).to match_array [case_2020, case_2021]
      end
    end

    describe ".for_term" do
      let!(:case_chicken) { create(:case, case_name: "contains the keyword ChickeN that we are looking for")}
      let!(:case_turkey) { create(:case, credit_details: "contains the keyword TurkeY that we are looking for")}
      let!(:case_goose) { create(:case, account_number: "contains the keyword GoosE that we are looking for")}

      it "finds cases with the keyword in case_name" do
        expect(Case.for_term("chiCkeN")).to match_array [case_chicken]
      end

      it "finds cases with the keyword in credit_details" do
        expect(Case.for_term("turKeY")).to match_array [case_turkey]
      end

      it "finds cases with the keyword in account_number" do
        expect(Case.for_term("gOOse")).to match_array [case_goose]
      end
    end
  end
end
