require "rails_helper"

RSpec.describe "Upload" do
  context "when not logged in" do
    it "redirects if not logged in" do
      get admin_upload_path
      expect(response).to be_redirect
    end
  end

  context "when logged in" do
    before do
      create(:user, name: "test_user", password: "mypass")
      request_login_as("test_user", "mypass")
    end

    it "shows upload page" do
      get admin_upload_path
      expect(response).to be_successful
      expect(response.body).to include("Upload CSV")
    end

    it "uploads a csv file" do
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("Upload CSV Complete")
    end

    it "handles missing file" do
      post admin_upload_path, params: { upload: { file: nil } }
      expect(response).to be_successful
      expect(response.body).to include("There is a problem", "Select a CSV file to upload")
    end

    it "handles clicking Upload again without reselecting a file after an error" do
      existing = create(:case)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("with_errors.csv") } }
      expect(response.body).to include("Row 4", "Upload failed. Row 4:")

      post admin_upload_path
      expect(response).to be_successful
      expect(response.body).to include("There is a problem", "Select a CSV file to upload")
      expect(response.body).not_to include("ParameterMissing", "Upload CSV Complete")
      expect(Case.all).to eq [existing]
    end

    it "handles an empty upload parameter" do
      post admin_upload_path, params: { upload: {} }
      expect(response).to be_successful
      expect(response.body).to include("Select a CSV file to upload")
    end

    it "shows the failing row and field instead of a completion page" do
      existing = create(:case)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("with_errors.csv") } }
      expect(response.body).to include("There is a problem", "Row 4", "Date Account must be a valid date", "No records were changed")
      expect(response.body).not_to include("Upload CSV Complete")
      expect(Case.all).to eq [existing]
    end

    it "explains an extra column on the upload page" do
      existing = create(:case)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("extra_column.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("Row 2", "Expected 8 columns, found 9", "No records were changed")
      expect(Case.all).to eq [existing]
    end

    it "shows the same grouped row errors in the red summary and field error" do
      details = (2..32).map { |line| { line:, message: "Date Account must be a valid date" } }
      details.last[:message] += "; Expected 8 columns, found 9"
      allow(CsvImporter).to receive(:import).and_return(added: 0, failed: details.size, errors: details.map { |error| error[:line] }, error_details: details)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response.body).to include("Upload failed.", "Rows #{(2..32).to_a.join(', ')}: Date Account must be a valid date", "Row 32: Expected 8 columns, found 9")
      document = Nokogiri::HTML(response.body)
      summary = document.at_css(".govuk-error-summary")
      field_error = document.at_css(".govuk-error-message")
      expected_detail = "Rows #{(2..32).to_a.join(', ')}: Date Account must be a valid date. Row 32: Expected 8 columns, found 9"
      expect(summary.text).to include(expected_detail)
      expect(field_error.text).to include(expected_detail)
      expect(response.body.scan("Date Account must be a valid date").size).to eq 2
      expect(response.body).not_to include("Errors in the CSV", "row contains errors", "rows contain errors")
      expect(response.body).not_to include("Showing the first")
    end

    it "explains a blank data row instead of showing a completion page" do
      post admin_upload_path, params: { upload: { file: fixture_file_upload("empty.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("Row 2", "Account number is missing")
      expect(response.body).not_to include("Upload CSV Complete")
    end

    it "shows a useful error if database replacement fails" do
      existing = create(:case)
      allow(Case).to receive(:import).and_raise(ActiveRecord::StatementInvalid)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("If it fails again, contact support", "No records were changed")
      expect(Case.all).to eq [existing]
    end

    it "explains a real duplicate-account upload and preserves existing records" do
      existing = create(:case)
      contents = File.read(file_fixture("test.csv"))
      duplicate_csv = contents + contents.lines.last
      Tempfile.create(["duplicate-accounts", ".csv"]) do |file|
        file.write(duplicate_csv)
        file.flush
        post admin_upload_path, params: { upload: { file: Rack::Test::UploadedFile.new(file.path, "text/csv") } }
      end
      expect(response.body).to include("The file contains repeated account numbers", "Case Number and Check Character", "No records were changed")
      expect(response.body).not_to include("File is invalid", "Upload CSV Complete", "PG::UniqueViolation")
      expect(Case.all).to eq [existing]
    end

    context "with different file contents" do
      let(:valid_contents) { File.read(file_fixture("test.csv")) }

      def upload_contents(contents, extension: ".csv")
        Tempfile.create(["manual-upload-case", extension]) do |file|
          file.binmode
          file.write(contents)
          file.flush
          post admin_upload_path, params: { upload: { file: Rack::Test::UploadedFile.new(file.path, "text/csv") } }
        end
      end

      def expect_rejected_upload(contents, message)
        existing = create(:case)
        upload_contents(contents)
        expect(response).to be_successful
        document = Nokogiri::HTML(response.body)
        expect(document.at_css(".govuk-error-summary").text).to include(message)
        expect(document.at_css(".govuk-error-message").text).to include(message)
        expect(response.body).not_to include("Upload CSV Complete")
        expect(Case.all).to eq [existing]
      end

      it "rejects a completely empty file" do
        expect_rejected_upload("", "at least one data row")
      end

      it "rejects a file with only headings" do
        expect_rejected_upload(valid_contents.lines.first, "at least one data row")
      end

      it "rejects plain text that is not a supported CSV layout" do
        expect_rejected_upload("This is not CSV data\nAnother line\n", "The CSV must contain 6 or 8 columns")
      end

      it "explains malformed CSV quotation marks" do
        expect_rejected_upload("#{valid_contents.lines.first}\"unterminated", "Check the commas and quotation marks")
      end

      it "rejects a seven-column header and data layout" do
        records = CSV.parse(valid_contents).map { |fields| fields.first(7) }
        contents = CSV.generate { |csv| records.each { |fields| csv << fields } }
        expect_rejected_upload(contents, "include either both optional date columns or neither")
      end

      it "identifies the row and column of a missing account date" do
        records = CSV.parse(valid_contents)
        records[1][4] = nil
        contents = CSV.generate { |csv| records.each { |fields| csv << fields } }
        expect_rejected_upload(contents, "Row 2: Date Account is missing. Enter the account date in column 5")
      end

      it "groups identical errors from real invalid CSV rows" do
        records = CSV.parse(valid_contents)
        records[1][4] = "31/02/2025"
        records[2][4] = "not-a-date"
        contents = CSV.generate { |csv| records.each { |fields| csv << fields } }
        expect_rejected_upload(contents, "Rows 2, 3: Date Account must be a valid date. Correct the date in column 5")
      end

      [".csv", ".CSV", ".txt"].each do |extension|
        it "accepts valid CSV contents with a #{extension} extension" do
          upload_contents(valid_contents, extension:)
          expect(response.body).to include("Upload CSV Complete")
          expect(Case.count).to eq 2
        end
      end

      it "accepts an Excel byte-order mark before the header" do
        upload_contents("\xEF\xBB\xBF".b + valid_contents.b)
        expect(response.body).to include("Upload CSV Complete")
        expect(Case.count).to eq 2
      end
    end

    it "retains the original generic error for uniqueness failures and preserves existing records" do
      existing = create(:case)
      allow(Case).to receive(:import).and_raise(ActiveRecord::RecordNotUnique)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("File is invalid")
      expect(response.body).not_to include("Duplicate account number", "scientific notation", "Upload CSV Complete")
      expect(Case.all).to eq [existing]
    end
  end
end
