class Upload
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :file, :results

  validates :file, presence: true

  def process
    @results = CsvImporter.import(File.open(file))
    true
  rescue StandardError
    errors.add(:file, :invalid)
    false
  end
end
