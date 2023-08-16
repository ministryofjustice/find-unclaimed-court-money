require "csv"

class CsvImporter
  def self.import(file)
    added = 0
    failed = 0
    errors = []
    cases = []

    CSV.foreach(file, headers: true, liberal_parsing: true, encoding: "iso-8859-1:utf-8").with_index(2) do |row, lineno|
      cases << CaseBuilder.build(
        case_number: row[0],
        year_carried: row[1],
        prime_index: row[2],
        check_character: row[3],
        date_account: row[4],
        credit_detail: row[5],
      )
    rescue StandardError
      failed += 1
      errors << lineno
    end

    if cases.present?
      ActiveRecord::Base.transaction do
        Case.delete_all
        imported = Case.import(cases)
        added = imported.ids.size
      end
    end

    { added:, failed:, errors: }
  end
end
