RSpec.describe CsvImporter do
  let(:csv) { file_fixture("test.csv") }
  let(:empty_csv) { file_fixture("empty.csv") }
  let(:with_errors_csv) { file_fixture("with_errors.csv") }
  let(:not_a_csv) { file_fixture("text.txt") }

  describe ".import" do
    context "with fully valid CSV" do
      it "deletes existing records and adds all records from the file" do
        count = 20
        create_list(:case, count)

        expect {
          described_class.import(csv)
        }.to change(Case, :count).from(count).to(2)
      end

      it "reports the number of successful lines" do
        expect(described_class.import(csv)[:added]).to eq 2
      end

      it "reports no failed lines" do
        expect(described_class.import(csv)[:failed]).to eq 0
      end
    end

    context "with CSV with errors" do
      it "returns details of the failing line", :aggregate_failures do
        expect(described_class.import(with_errors_csv)[:failed]).to eq 1
        expect(described_class.import(with_errors_csv)[:errors]).to eq [4]
      end
    end

    context "when not a CSV file" do
      it "does not delete existing records" do
        create_list(:case, 20)

        expect {
          described_class.import(not_a_csv)
        }.not_to change(Case, :count)
      end
    end
  end
end
