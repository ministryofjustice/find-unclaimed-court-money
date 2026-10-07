require "csv"

class CsvImporter
  class InvalidFile < StandardError; end

  def self.import(file)
    cases = []
    errors = []
    column_count = nil

    CSV.foreach(file, headers: true, liberal_parsing: true, encoding: "iso-8859-1:utf-8").with_index(2) do |row, lineno|
      # Spreadsheet exports may include an unused final column with no heading.
      column_count ||= row.headers.reverse.drop_while(&:blank?).size
      unless [6, 8].include?(column_count)
        raise InvalidFile, "The CSV must contain 6 or 8 columns. Check the header row and include either both optional date columns or neither. No records were changed."
      end

      reasons = []
      if row.fields.size < column_count || row.fields.drop(column_count).any?(&:present?)
        reasons << "Expected #{column_count} columns, found #{row.fields.size}. Check column #{column_count + 1} for extra data, or restore missing columns"
      end
      account = "#{row[0]}#{row[3]}"
      if account.blank?
        reasons << "Account number is missing. Check Case Number in column 1 and Check Character in column 4"

      end

      if row[4].blank?
        reasons << "Date Account is missing. Enter the account date in column 5"
      else
        begin
          Date.parse(row[4])
        rescue ArgumentError
          reasons << "Date Account must be a valid date. Correct the date in column 5, for example 26/07/2024"
        end
      end

      if reasons.empty?
        cases << CaseBuilder.build(
          case_number: row[0],
          year_carried: row[1],
          prime_index: row[2],
          check_character: row[3],
          date_account: row[4],
          credit_detail: row[5],
          initial_dormancy: row[6],
          last_claim_date: row[7],
        )
      else
        errors << { line: lineno, message: reasons.join("; ") }
      end
    end

    raise InvalidFile, "The CSV must contain a header and at least one data row. No records were changed." if cases.empty? && errors.empty?

    added = 0
    if errors.empty?
      ActiveRecord::Base.transaction do
        Case.delete_all
        imported = Case.import(cases)
        raise InvalidFile, "Some records could not be saved. Check account numbers in the CSV. No records were changed." if imported.failed_instances.any?

        added = imported.ids.size
      end
    end

    { added:, failed: errors.size, errors: errors.map { |error| error[:line] }, error_details: errors }
  rescue CSV::MalformedCSVError => e
    raise InvalidFile, "The CSV could not be read near line #{e.line_number}. Check the commas and quotation marks. No records were changed."
  end
end
