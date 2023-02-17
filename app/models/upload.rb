class Upload
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :file

  validates :file, presence: true

  def process
    CsvImporter.import(File.open(file))
  end
end
