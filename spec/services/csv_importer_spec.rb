require "rails_helper"

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
        }.to raise_error(CsvImporter::InvalidFile)
        expect(Case.count).to eq 20
      end
    end
  end

  describe "CSV validation" do
    let(:headers) { ["Case Number", "Year Carried", "Prime Index", "Check Character", "Date Account", "Credit Detail", "Dormancy Date", "Last Claim Date"] }
    let(:row) { ["12345", "2022", "Example case", "A", "06/12/2011", nil, "25/03/2022", "15/07/2019"] }

    def import_rows(rows, headings: headers)
      described_class.import(StringIO.new(CSV.generate do |csv|
        csv << headings
        rows.each { |fields| csv << fields }
      end))
    end

    it "keeps CaseBuilder and the existing positional date mapping" do
      expect(CaseBuilder).to receive(:build).and_call_original
      import_rows([row])
      expect(Case.first.initial_dormancy).to eq "25/03/2022"
      expect(Case.first.last_claim_date).to eq "15/07/2019"
    end

    it "supports existing six-column files" do
      expect(import_rows([row.first(6)], headings: headers.first(6))[:added]).to eq 1
    end

    it "accepts a missing optional final date" do
      row[7] = nil
      expect(import_rows([row])[:added]).to eq 1
      expect(Case.first.last_claim_date).to be_nil
    end

    it "does not add new year, prime-index or optional-date restrictions" do
      row[1] = "22"
      row[2] = nil
      row[7] = "unknown"
      expect(import_rows([row])[:added]).to eq 1
    end

    it "rejects the ticket's extra x in an unnamed column without replacing records" do
      existing = create(:case)
      results = import_rows([row + [nil], row + %w[x]], headings: headers + [nil])
      expect(results[:added]).to eq 0
      expect(results[:error_details]).to include(line: 3, message: "Expected 8 columns, found 9. Check column 9 for extra data, or restore missing columns")
      expect(Case.all).to eq [existing]
    end

    it "accepts an unused trailing column from a spreadsheet export" do
      expect(import_rows([row + [nil]], headings: headers + [nil])[:added]).to eq 1
    end

    it "retains database uniqueness enforcement and rolls back a duplicate upload" do
      existing = create(:case)
      row[0] = "1.20E+11"
      expect { import_rows([row, row]) }.to raise_error(ActiveRecord::RecordNotUnique)
      expect(Case.all).to eq [existing]
    end

    it "identifies a missing Date Account" do
      row[4] = nil
      expect(import_rows([row])[:error_details]).to eq [{ line: 2, message: "Date Account is missing. Enter the account date in column 5" }]
    end

    it "rejects an unsupported column layout without deleting existing records" do
      existing = create(:case)
      expect { import_rows([row.first(7)], headings: headers.first(7)) }.to raise_error(CsvImporter::InvalidFile, "The CSV must contain 6 or 8 columns. Check the header row and include either both optional date columns or neither. No records were changed.")
      expect(Case.all).to eq [existing]
    end

    it "rejects empty and header-only files" do
      expect { import_rows([]) }.to raise_error(CsvImporter::InvalidFile, /at least one/)
      expect { described_class.import(StringIO.new("")) }.to raise_error(CsvImporter::InvalidFile)
    end

    it "accepts a leap-day Date Account in a leap year" do
      row[4] = "29/02/2024"
      expect(import_rows([row])[:added]).to eq 1
      expect(Case.first.case_date).to eq Date.new(2024, 2, 29)
    end

    it "retains support for dates accepted by the original parser" do
      row[4] = "2024-02-29"
      expect(import_rows([row])[:added]).to eq 1
      expect(Case.first.case_date).to eq Date.new(2024, 2, 29)
    end

    it "preserves quoted commas, quotation marks and line breaks in data" do
      row[2] = 'Example, "quoted" case'
      row[5] = "First line\nSecond line, credit detail"
      expect(import_rows([row])[:added]).to eq 1
      expect(Case.first.case_name).to eq row[2]
      expect(Case.first.credit_details).to eq row[5]
    end

    it "accepts blank credit details and both optional dates" do
      row[5..7] = [nil, nil, nil]
      expect(import_rows([row])[:added]).to eq 1
      expect(Case.first.attributes).to include("credit_details" => nil, "initial_dormancy" => nil, "last_claim_date" => nil)
    end

    it "replaces an existing account with its updated data" do
      existing = create(:case, account_number: "12345A")
      row[2] = "Updated case name"
      expect(import_rows([row])[:added]).to eq 1
      expect(Case.exists?(existing.id)).to be false
      expect(Case.find_by!(account_number: "12345A").case_name).to eq "Updated case name"
    end

    it "accepts different check characters for the same case number" do
      second_row = row.dup
      second_row[3] = "B"
      expect(import_rows([row, second_row])[:added]).to eq 2
      expect(Case.pluck(:account_number)).to contain_exactly("12345A", "12345B")
    end

    ["not-a-date", "31/02/2025", "29/02/2023", "01/13/2025"].each do |invalid_date|
      it "rejects invalid Date Account #{invalid_date} without replacing valid records" do
        existing = create(:case)
        invalid_row = row.dup
        invalid_row[0] = "67890"
        invalid_row[4] = invalid_date
        results = import_rows([row, invalid_row])
        expect(results).to include(added: 0, failed: 1, errors: [3])
        expect(results[:error_details]).to eq [{ line: 3, message: "Date Account must be a valid date. Correct the date in column 5, for example 26/07/2024" }]
        expect(Case.all).to eq [existing]
      end
    end

    it "reports a missing combined account number and missing date on the same row" do
      row[0] = nil
      row[3] = nil
      row[4] = nil
      results = import_rows([row])
      expect(results).to include(added: 0, failed: 1, errors: [2])
      expect(results[:error_details]).to eq [{ line: 2, message: "Account number is missing. Check Case Number in column 1 and Check Character in column 4; Date Account is missing. Enter the account date in column 5" }]
    end

    it "accepts an omitted optional final column as a blank date" do
      expect(import_rows([row.first(7)])[:added]).to eq 1
      expect(Case.first.last_claim_date).to be_nil
    end

    it "rejects a truncated row missing Date Account without replacing records" do
      existing = create(:case)
      results = import_rows([row.first(4)])
      expect(results[:error_details]).to eq [{ line: 2, message: "Date Account is missing. Enter the account date in column 5" }]
      expect(Case.all).to eq [existing]
    end

    it "rejects extra populated columns in a six-column file" do
      results = import_rows([row.first(6) + %w[x]], headings: headers.first(6))
      expect(results[:added]).to eq 0
      expect(results[:error_details]).to eq [{ line: 2, message: "Expected 6 columns, found 7. Check column 7 for extra data, or restore missing columns" }]
    end

    it "reports a malformed quoted row without replacing existing records" do
      existing = create(:case)
      malformed_csv = "#{CSV.generate_line(headers)}\"unterminated"
      expect { described_class.import(StringIO.new(malformed_csv)) }.to raise_error(CsvImporter::InvalidFile, /Check the commas and quotation marks/)
      expect(Case.all).to eq [existing]
    end

    it "rolls back deletion if model validation rejects an imported case" do
      existing = create(:case)
      result = ActiveRecord::Import::Result.new([Case.new], 0, [], [])
      allow(Case).to receive(:import).and_return(result)
      expect { import_rows([row]) }.to raise_error(CsvImporter::InvalidFile, /Some records could not be saved/)
      expect(Case.all).to eq [existing]
    end

    it "rolls back deletion if database insertion fails" do
      existing = create(:case)
      allow(Case).to receive(:import).and_raise(ActiveRecord::StatementInvalid)
      expect { import_rows([row]) }.to raise_error(ActiveRecord::StatementInvalid)
      expect(Case.all).to eq [existing]
    end
  end
end
