require "csv"

class CsvImporter
  def self.import(file)
    results = { added: 0, failed: 0, errors: [] }

    ActiveRecord::Base.transaction do
      Case.delete_all
      CSV.foreach(file, headers: true, liberal_parsing: true, encoding: "iso-8859-1:utf-8").with_index(2) do |row, lineno|
        begin
          kase = CaseCreator.call(
            case_number: row[0],
            year_carried: row[1],
            prime_index: row[2],
            check_character: row[3],
            date_account: row[4],
            credit_detail: row[5],
          )
          results[:added] += 1
        rescue => e
          results[:failed] += 1
          results[:errors] << lineno
        end
      end
    end

    results
  end
end
