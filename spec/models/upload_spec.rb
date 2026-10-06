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
        allow(CsvImporter).to receive(:import).and_return({ added: 2, failed: 0, errors: [], error_details: [] })
      end

      it { is_expected.to be_truthy }
    end

    it "displays the specific invalid-file message and returns failure" do
      message = "The CSV must contain 6 or 8 columns. Check the header row and include either both optional date columns or neither. No records were changed."
      allow(CsvImporter).to receive(:import).and_raise(CsvImporter::InvalidFile, message)

      expect(process).to be false
      expect(upload.errors[:file]).to eq [message]
    end

    it "explains a confirmed account-number conflict without displaying internal database details" do
      result = instance_double(PG::Result)
      allow(result).to receive(:error_field).with(PG::Result::PG_DIAG_CONSTRAINT_NAME).and_return("index_cases_on_account_number")
      error = ActiveRecord::RecordNotUnique.new("internal database details")
      allow(error).to receive(:cause).and_return(instance_double(PG::UniqueViolation, result:))
      allow(CsvImporter).to receive(:import).and_raise(error)

      expect(process).to be false
      expect(upload.errors[:file]).to eq ["The file contains repeated account numbers. Check the Case Number and Check Character columns, then upload again. No records were changed."]
      expect(upload.errors[:file].join).not_to include("internal database details")
    end

    context "with invalid file" do
      before do
        allow(CsvImporter).to receive(:import).and_raise
      end

      it { is_expected.to be_falsy }

      it "adds an error" do
        process
        expect(upload.errors.first.message).to include("If it fails again, contact support", "No records were changed")
      end
    end
  end
end
