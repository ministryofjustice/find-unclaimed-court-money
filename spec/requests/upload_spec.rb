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
      expect(response.body).to include("Row 4", "1 row contains errors")

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

    it "shows each unique error once with all affected row numbers" do
      details = (2..32).map { |line| { line:, message: "Duplicate account number in this file" } }
      details.last[:message] += "; Expected 8 columns, found 9"
      allow(CsvImporter).to receive(:import).and_return(added: 0, failed: details.size, errors: details.map { |error| error[:line] }, error_details: details)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response.body).to include("31 rows contain errors", "Rows #{(2..32).to_a.join(', ')}: Duplicate account number", "Row 32: Expected 8 columns, found 9")
      expect(response.body.scan("Duplicate account number in this file").size).to eq 1
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

    it "shows the save-failure message for an unidentified uniqueness conflict and preserves existing records" do
      existing = create(:case)
      allow(Case).to receive(:import).and_raise(ActiveRecord::RecordNotUnique)
      post admin_upload_path, params: { upload: { file: fixture_file_upload("test.csv") } }
      expect(response).to be_successful
      expect(response.body).to include("The file could not be saved.", "Try uploading again", "No records were changed")
      expect(response.body).not_to include("database conflict")
      expect(Case.all).to eq [existing]
    end
  end
end
