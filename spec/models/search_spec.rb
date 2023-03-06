RSpec.describe Search do
  subject(:search) { build(:search) }

  it { is_expected.to be_valid }

  context "with only keywords" do
    subject(:search) { described_class.new(keywords: "test") }

    it { is_expected.to be_valid }
  end

  context "with empty keywords" do
    subject(:search) { described_class.new(keywords: "") }

    it { is_expected.not_to be_valid }
  end

  context "with too short keywords" do
    subject(:search) { described_class.new(keywords: "aa") }

    it { is_expected.not_to be_valid }
  end

  context "with invalid date_from" do
    subject(:search) { build(:search, date_from: { 3 => 1, 2 => nil, 1 => 1990 }) }

    it { is_expected.not_to be_valid }
  end

  context "with invalid date_to" do
    subject(:search) { build(:search, date_to: { 3 => 31, 2 => nil, 1 => 2020 }) }

    it { is_expected.not_to be_valid }
  end

  context "with only dates" do
    subject(:search) { build(:search, keywords: nil, date_from: { 3 => 31, 2 => 1, 1 => 2020 }, date_to: { 3 => 31, 2 => 1, 1 => 2021 }) }

    it { is_expected.to be_valid }
  end

  describe "#results" do
    it "orders by most recent case date" do
      case_2000 = create(:case, case_name: "test", case_date: Date.new(2000))
      case_2001 = create(:case, case_name: "test", case_date: Date.new(2001))
      case_2002 = create(:case, case_name: "test", case_date: Date.new(2002))

      search = described_class.new(keywords: "test")

      expect(search.results).to eq [case_2002, case_2001, case_2000]
    end

    context "when using scopes" do
      let(:kase) { object_double(Case) }

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
        allow(Case).to receive(:for_term).with("test1").and_return(kase)
        allow(kase).to receive(:or).with(Case.for_term("test2")).and_return(kase)
        search.results
      end
    end
  end
end
