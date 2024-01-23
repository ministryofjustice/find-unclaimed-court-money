FactoryBot.define do
  factory :case do
    sequence(:account_number) { |n| "ABC#{n}" }
    year_carried_over { "2010" }
    case_name { "Joe Bloggs" }
    date_account_opened { "02/03/1996" }
    case_date { Date.new(1996, 2, 3) }
    credit_details { "lorum ipsum" }
    last_claim_date { "07/09/2020" }
    initial_dormancy { "03/03/2015" }
  end
end
