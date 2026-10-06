class Upload
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :file, :results

  validates :file, presence: true

  def process
    File.open(file) { |csv| @results = CsvImporter.import(csv) }
    if results[:failed].positive?
      errors.add(:file, "Upload failed: #{results[:failed]} #{'row'.pluralize(results[:failed])} #{results[:failed] == 1 ? 'contains' : 'contain'} errors. No records were changed.")
      return false
    end
    true
  rescue CsvImporter::InvalidFile => e
    errors.add(:file, e.message)
    false
  rescue StandardError => e
    Rails.logger.error("CSV upload failed (#{e.class})")
    errors.add(:file, "The file could not be saved. Try uploading again. If it fails again, contact support. No records were changed.")
    false
  end
end
