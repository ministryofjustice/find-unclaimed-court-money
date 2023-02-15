RSpec.describe Search, type: :model do
  subject { build(:search) }

  describe "Validations" do
    it "is valid with only keywords" do
      subject = Search.new(keywords: "test")
      expect(subject).to be_valid
    end

    it "is not valid without keywords" do
      subject.keywords = nil
      expect(subject).to_not be_valid
    end

    it "is not valid with too short keywords" do
      subject.keywords = "aa"
      expect(subject).to_not be_valid
    end

    it "is not valid with incorrect date_from" do
      subject.date_from = {
        "date_from(1i)" => "1990",
        "date_from(2i)" => "invalid",
        "date_from(3i)" => "12"
      }
      expect(subject).to_not be_valid
    end

    it "is not valid with incorrect date_to" do
      subject.date_from = {
        "date_to(1i)" => "1990",
        "date_to(2i)" => "invalid",
        "date_to(3i)" => "12"
      }
      expect(subject).to_not be_valid
    end
  end

  describe "#results" do
    it "orders by most recent case date" do
      case_2000 = create(:case, account_number: "test", case_date: Date.new(2000))
      case_2001 = create(:case, account_number: "test", case_date: Date.new(2001))
      case_2002 = create(:case, account_number: "test", case_date: Date.new(2002))

      search = Search.new(keywords: "test")

      expect(search.results).to eq [case_2002, case_2001, case_2000]
    end

    context "using scopes" do
      let(:kase) { double(Case) }

      before do
        allow(Case).to receive(:for_term).and_return(kase)
        allow(kase).to receive(:to_date).and_return(kase)
        allow(kase).to receive(:from_date).and_return(kase)
        allow(kase).to receive(:order).and_return(kase)
      end

      it "filters by from date using a scope" do
        expect(kase).to receive(:from_date).with(subject.date_from)
        subject.results
      end

      it "filters by to date using a scope" do
        expect(kase).to receive(:to_date).with(subject.date_to)
        subject.results
      end

      it "filters by one keyword" do
        expect(Case).to receive(:for_term).with(subject.keywords)
        subject.results
      end

      it "filters by multiple keywords" do
        subject.keywords = "test1,test2"
        expect(Case).to receive(:for_term).with("test1").and_return(kase)
        expect(kase).to receive(:or).with(Case.for_term("test2")).and_return(kase)
        subject.results
      end
    end
  end
end
