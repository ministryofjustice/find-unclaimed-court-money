RSpec.configure do |config|
  config.before(:suite) do
    system("yarn build", out: File::NULL)
    system("yarn build:css", out: File::NULL)
  end
end
