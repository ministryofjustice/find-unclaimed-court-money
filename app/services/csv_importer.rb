require "csv"

class CsvImporter
  def self.import(file)
    removed = Case.count
    Case.delete_all

    failed = 0
    errors = []
    cases = []
    CSV.foreach(file, headers: true, liberal_parsing: true, encoding: "iso-8859-1:utf-8").with_index(2) do |row, lineno|
      begin
        cases << CaseCreator.build(
          case_number: row[0],
          year_carried: row[1],
          prime_index: row[2],
          check_character: row[3],
          date_account: row[4],
          credit_detail: row[5],
        )
      rescue => e
        failed += 1
        errors << lineno
      end
    end
    results = Case.import(cases)

    { added: results.ids.size, failed:, removed:, errors: }
  end
end
