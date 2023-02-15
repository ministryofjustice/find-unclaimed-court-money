RSpec.describe Search, type: :model do
  let(:search) { build(:search) }

  describe "Validations" do
    it "is valid with only keywords" do
      search = described_class.new(keywords: "test")
      expect(search).to be_valid
    end

    it "is not valid without keywords" do
      search.keywords = nil
      expect(search).not_to be_valid
    end

    it "is not valid with too short keywords" do
      search.keywords = "aa"
      expect(search).not_to be_valid
    end

    it "is not valid with incorrect date_from" do
      search.date_from = {
        "date_from(1i)" => "1990",
        "date_from(2i)" => "invalid",
        "date_from(3i)" => "12",
      }
      expect(search).not_to be_valid
    end

    it "is not valid with incorrect date_to" do
      search.date_from = {
        "date_to(1i)" => "1990",
        "date_to(2i)" => "invalid",
        "date_to(3i)" => "12",
      }
      expect(search).not_to be_valid
    end
  end

  describe "#results" do
    it "orders by most recent case date" do
      case_2000 = create(:case, account_number: "test", case_date: Date.new(2000))
      case_2001 = create(:case, account_number: "test", case_date: Date.new(2001))
      case_2002 = create(:case, account_number: "test", case_date: Date.new(2002))

      search = described_class.new(keywords: "test")

      expect(search.results).to eq [case_2002, case_2001, case_2000]
    end

    context "when using scopes" do
      let(:kase) { double("case") }

      before do
        allow(Case).to receive(:for_term).and_return(kase)
        allow(kase).to receive(:to_date).and_return(kase)
        allow(kase).to receive(:from_date).and_return(kase)
        allow(kase).to receive(:order).and_return(kase)
      end

      it "filters by from date using a scope" do
        expect(kase).to receive(:from_date).with(search.date_from)
        search.results
      end

      it "filters by to date using a scope" do
        expect(kase).to receive(:to_date).with(search.date_to)
        search.results
      end

      it "filters by one keyword" do
        expect(Case).to receive(:for_term).with(search.keywords)
        search.results
      end

      it "filters by multiple keywords" do
        search.keywords = "test1,test2"
        expect(Case).to receive(:for_term).with("test1").and_return(kase)
        expect(kase).to receive(:or).with(Case.for_term("test2")).and_return(kase)
        search.results
      end
    end
  end
end
