require 'csv'

class CsvImporter
  def self.import(file)
    Case.delete_all
    CSV.foreach(file, headers: true, liberal_parsing: true, encoding:'iso-8859-1:utf-8') do |row|
      begin
        kase = CaseCreator.call(
          case_number: row[0],
          year_carried: row[1],
          prime_index: row[2],
          check_character: row[3],
          date_account: row[4],
          credit_detail: row[5]
        )
        puts "Added #{ kase.account_number}"
      rescue => e
        puts "error!"
        puts e.message
        puts "HERE"
        puts row
      end
    end
  end
end
