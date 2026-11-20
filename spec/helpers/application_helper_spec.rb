RSpec.describe ApplicationHelper do
  describe "to_csv_path" do
    it "converts a URL path to CSV format" do
      url = "https://test.com/my/path?param=1"
      expect(helper.to_csv_path(url)).to eq "https://test.com/my/path.csv?param=1"
    end
  end

  describe "govuk_pagination_with_link_labels" do
    it "adds aria-labels to pagination links" do
      pagy = double("Pagy", pages: 3, page: 1)
      allow(helper).to receive(:govuk_pagination).with(pagy: pagy).
        and_return('<nav class="govuk-pagination"><ul class="govuk-pagination__list"><li class="govuk-pagination__item"><a class="govuk-pagination__link" href="?page=1">1</a></li><li class="govuk-pagination__item"><a class="govuk-pagination__link" href="?page=2">2</a></li><li class="govuk-pagination__item"><a class="govuk-pagination__link" href="?page=3">3</a></li></ul></nav>')
      result = helper.govuk_pagination_with_link_labels(pagy: pagy)
      expect(result).to include('aria-label="Page 1"')
      expect(result).to include('aria-label="Page 2"')
      expect(result).to include('aria-label="Page 3"')
    end
  end

  it "returns nil when pagination HTML is blank" do
    pagy = double("Pagy", pages: 0, page: 1)
    allow(helper).to receive(:govuk_pagination).with(pagy: pagy).and_return("")
    result = helper.govuk_pagination_with_link_labels(pagy: pagy)
    expect(result).to be_nil
  end

  it "returns current page when it is on a page" do
    pagy = double("Pagy", pages: 3, page: 2)
    allow(helper).to receive(:govuk_pagination).with(pagy: pagy).
      and_return('<li class="govuk-pagination__item govuk-pagination__item--current"><a class="govuk-link govuk-pagination__link" href="#" aria-label="Page 2" aria-current="page">2</a></li>')
    result = helper.govuk_pagination_with_link_labels(pagy: pagy)
    expect(result).to include('govuk-pagination__item--current')
  end

  it "returns next link when it is on a page" do
    pagy = double("Pagy", pages: 3, page: 2)
    allow(helper).to receive(:govuk_pagination).with(pagy: pagy).
      and_return('<div class="govuk-pagination__next">
    <a class="govuk-link govuk-pagination__link" href="#" rel="next"><span class="govuk-pagination__link-title">Next<span class="govuk-visually-hidden"> page</span></span><svg class="govuk-pagination__icon govuk-pagination__icon--next" xmlns="http://www.w3.org/2000/svg" height="13" width="15" aria-hidden="true" focusable="false" viewBox="0 0 15 13"><path d="m8.107-0.0078125-1.4136 1.414 4.2926 4.293h-12.986v2h12.896l-4.1855 3.9766 1.377 1.4492 6.7441-6.4062-6.7246-6.7266z"></path></svg></a></div>')
    result = helper.govuk_pagination_with_link_labels(pagy: pagy)
    expect(result).to include('govuk-pagination__item--next')
    expect(result).to include('govuk-pagination__icon--next')
  end

  it "returns previous link with arrow when it is on a page" do
    pagy = double("Pagy", pages: 3, page: 2)
    allow(helper).to receive(:govuk_pagination).with(pagy: pagy).
      and_return('<div class="govuk-pagination__prev"><a class="govuk-link govuk-pagination__link" href="#" rel="prev"><svg class="govuk-pagination__icon govuk-pagination__icon--prev" xmlns="http://www.w3.org/2000/svg" height="13" width="15" aria-hidden="true" focusable="false" viewBox="0 0 15 13"><path d="m6.5938-0.0078125-6.7266 6.7266 6.7441 6.4062 1.377-1.449-4.1856-3.9768h12.896v-2h-12.984l4.2931-4.293-1.414-1.414z"></path></svg><span class="govuk-pagination__link-title">Previous<span class="govuk-visually-hidden"> page</span></span></a></div>')
    result = helper.govuk_pagination_with_link_labels(pagy: pagy)
    expect(result).to include('govuk-pagination__item--prev')
    expect(result).to include('govuk-pagination__icon--prev')
  end
end
