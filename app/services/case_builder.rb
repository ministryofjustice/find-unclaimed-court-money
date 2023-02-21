class CaseBuilder
  def self.build(case_number:, year_carried:, prime_index:, check_character:, date_account:, credit_detail:)
    Case.new(
      year_carried_over: year_carried,
      case_name: prime_index,
      date_account_opened: date_account,
      credit_details: credit_detail,
      account_number: "#{case_number}#{check_character}",
      case_date: Date.parse(date_account),
    )
  end
end
