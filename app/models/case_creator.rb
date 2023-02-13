class CaseCreator
  def self.call(case_number:, year_carried:, prime_index:, check_character:, date_account:, credit_detail:)
    kase = Case.new(
      year_carried_over: year_carried,
      case_name: prime_index,
      date_account_opened: date_account,
      credit_details: credit_detail
    )

    kase.account_number = "#{case_number}#{check_character}"
    kase.case_date = Date.parse(date_account)

    kase.save!
    kase
  end
end
