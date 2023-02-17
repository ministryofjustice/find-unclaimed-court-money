FactoryBot.define do
  factory :case do
    sequence(:account_number) { |n| "ABC#{n}" }
    year_carried_over { "2010" }
    case_name { "Joe Bloggs" }
    date_account_opened { "02/03/1996" }
    case_date { Date.new(1996, 2, 3) }
    credit_details { "lorum ipsum" }
  end
end
