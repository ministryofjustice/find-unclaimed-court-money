module ApplicationHelper
  def to_csv_path(url)
    url.gsub("?", ".csv?")
  end
end
