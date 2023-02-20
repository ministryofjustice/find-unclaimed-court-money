FactoryBot.define do
  factory :upload do
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.csv")) }
  end
end
