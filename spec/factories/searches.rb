FactoryBot.define do
  factory :search do
    keywords { "test" }
    date_from do
      {
        "date_from(1i)"=>"1990",
        "date_from(2i)"=>"1",
        "date_from(3i)"=>"1"
      }
    end
    date_to do
      {
        "date_to(1i)"=>"2020",
        "date_to(2i)"=>"12",
        "date_to(3i)"=>"31"
      }
    end
  end
end
