class Upload
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :file, :results

  validates :file, presence: true

  def process
    File.open(file) { |csv| @results = CsvImporter.import(csv) }
    if results[:failed].positive?
      grouped_errors = results[:error_details].each_with_object({}) do |error, groups|
        error[:message].split("; ").each do |message|
          (groups[message] ||= []) << error[:line]
        end
      end
      details = grouped_errors.map { |message, rows|
        "#{'Row'.pluralize(rows.size)} #{rows.join(', ')}: #{message}"
      }.join(". ")
      errors.add(:file, "Upload failed. #{details}. No records were changed.")
      return false
    end
    true
  rescue CsvImporter::InvalidFile => e
    errors.add(:file, e.message)
    false
  rescue ActiveRecord::RecordNotUnique => e
    constraint = e.cause.respond_to?(:result) ? e.cause.result.error_field(PG::Result::PG_DIAG_CONSTRAINT_NAME) : nil
    if constraint == "index_cases_on_account_number"
      errors.add(:file, "The file contains repeated account numbers. Check the Case Number and Check Character columns, then upload again. No records were changed.")
    else
      errors.add(:file, :invalid)
    end
    false
  rescue StandardError => e
    Rails.logger.error("CSV upload failed (#{e.class})")
    errors.add(:file, "The file could not be saved. Try uploading again. If it fails again, contact support. No records were changed.")
    false
  end
end
