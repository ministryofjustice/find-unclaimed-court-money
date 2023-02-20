RSpec.describe Upload do
  subject { build(:upload) }

  it { is_expected.to be_valid }

  context "when file does not exist" do
    subject { build(:upload, file: nil) }

    it { is_expected.not_to be_valid }
  end

  describe "#process" do
    subject(:process) { upload.process }

    let(:upload) { build(:upload) }

    context "with valid file" do
      before do
        allow(CsvImporter).to receive(:import).and_return({})
      end

      it { is_expected.to be_truthy }
    end

    context "with invalid file" do
      before do
        allow(CsvImporter).to receive(:import).and_raise
      end

      it { is_expected.to be_falsy }

      it "adds an error" do
        process
        expect(upload.errors.first.type).to eq :invalid
      end
    end
  end
end
