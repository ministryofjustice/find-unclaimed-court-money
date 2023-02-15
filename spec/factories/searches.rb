FactoryBot.define do
  factory :search do
    keywords { "test" }
    date_from { { 3 => 1, 2 => 1, 1 => 1990 } }
    date_to { { 3 => 31, 2 => 12, 1 => 2020 } }
  end
end
