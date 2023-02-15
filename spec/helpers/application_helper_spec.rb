RSpec.describe ApplicationHelper do
  describe "to_csv_path" do
    it "converts a URL path to CSV format" do
      url = "https://test.com/my/path?param=1"
      expect(helper.to_csv_path(url)).to eq "https://test.com/my/path.csv?param=1"
    end
  end
end
