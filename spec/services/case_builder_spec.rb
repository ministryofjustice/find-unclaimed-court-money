RSpec.describe CaseBuilder do
  let(:case_number) { "12345" }
  let(:year_carried) { "1960" }
  let(:prime_index) { "Mr Smith vs Mrs Smith" }
  let(:check_character) { "A" }
  let(:date_account) { "20/12/1955" }
  let(:credit_detail) { "the credit detail" }
  let(:last_claim_date) { "01/01/2000" }
  let(:initial_dormancy) { "04/05/1977" }

  describe ".build" do
    let(:kase) do
      described_class.build(
        case_number:, year_carried:, prime_index:, check_character:, date_account:, credit_detail:, last_claim_date:, initial_dormancy:,
      )
    end

    it "builds a case with expected values", :aggregate_failures do
      expect(kase.account_number).to eq "12345A"
      expect(kase.year_carried_over).to eq year_carried
      expect(kase.case_name).to eq prime_index
      expect(kase.date_account_opened).to eq date_account
      expect(kase.credit_details).to eq credit_detail
      expect(kase.case_date).to eq Date.new(1955, 12, 20)
      expect(kase.last_claim_date).to eq last_claim_date
      expect(kase.initial_dormancy).to eq initial_dormancy
    end
  end
end
