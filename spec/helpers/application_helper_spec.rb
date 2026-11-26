RSpec.describe ApplicationHelper do
  describe "to_csv_path" do
    it "converts a URL path to CSV format" do
      url = "https://test.com/my/path?param=1"
      expect(helper.to_csv_path(url)).to eq "https://test.com/my/path.csv?param=1"
    end
  end

  describe "govuk_pagination_with_link_labels" do
    subject(:result) { helper.govuk_pagination_with_link_labels(pagy: pagy) }

    let(:pagy) { instance_double(Pagy, pages: pages) }

    before do
      allow(helper).to receive(:govuk_pagination).with(pagy: pagy).and_return(govuk_pagination_html)
    end

    context "with numbered page links" do
      let(:pages) { 3 }
      let(:govuk_pagination_html) do
        <<~HTML
          <ul class="govuk-pagination__list">
            <li class="govuk-pagination__item" aria-label="Page 1">
              <a class="govuk-link govuk-pagination__link" href="?page=1">1</a>
            </li>
            <li class="govuk-pagination__item" aria-label="Page 2">
              <a class="govuk-link govuk-pagination__link" href="?page=2">2</a>
            </li>
            <li class="govuk-pagination__item" aria-label="Page 3">
              <a class="govuk-link govuk-pagination__link" href="?page=3">3</a>
            </li>
          </ul>
        HTML
      end

      it "moves the 'Page N' label onto each link" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        links = doc.css("a.govuk-pagination__link")
        expect(links.map { |link| link["aria-label"] }).to eq(["Page 1", "Page 2", "Page 3"])
      end

      it "removes the now-redundant aria-label from the list item" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        expect(doc.css("li.govuk-pagination__item").map { |li| li["aria-label"] }).to all(be_nil)
      end
    end

    context "with single page numbered with no link" do
      let(:pages) { 1 }
      let(:govuk_pagination_html) do
        <<~HTML
          <ul class="govuk-pagination__list">
            <li class="govuk-pagination__item">
              <a class="govuk-link govuk-pagination__link" href="?page=1" aria-label="Page 1">1</a>
            </li>
          </ul>
        HTML
      end

      it "has the correct page number" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        link = doc.css("a.govuk-pagination__link").first
        expect(link["aria-label"]).to eq("Page 1")
      end
    end

    context "with previous page" do
      let(:pages) { 3 }
      let(:govuk_pagination_html) do
        <<~HTML
          <div class="govuk-pagination__prev"><a href="?page=1" class="govuk-link govuk-pagination__link" rel="prev"><svg class="govuk-pagination__icon govuk-pagination__icon--prev"></svg><span class="govuk-pagination__link-title govuk-pagination__link-title--decorated">Previous<span class="govuk-visually-hidden"> page</span></span></a></div>
          <ul class="govuk-pagination__list">
            <li class="govuk-pagination__item" aria-label="Page 1"><a href="?page=1" class="govuk-link govuk-pagination__link">1</a></li>
            <li class="govuk-pagination__item govuk-pagination__item--current" aria-label="Page 2"><a href="?page=2" class="govuk-link govuk-pagination__link">2</a></li>
            <li class="govuk-pagination__item" aria-label="Page 3"><a href="?page=3" class="govuk-link govuk-pagination__link">3</a></li>
          </ul>
        HTML
      end

      it "returns previous with a link when on the second page" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        expect(doc.css("div.govuk-pagination__prev")).not_to be_empty
        link = doc.css("a.govuk-pagination__link").first
        expect(link["rel"]).to eq("prev")
      end

      it "displays the icon within previous link" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        link = doc.css("a.govuk-pagination__link").first
        expect(link["rel"]).to eq("prev")
      end
    end

    context "without previous page link" do
      let(:pages) { 3 }
      let(:govuk_pagination_html) do
        <<~HTML
          <ul class="govuk-pagination__list">
            <li class="govuk-pagination__item govuk-pagination__item--current" aria-label="Page 1"><a href="?page=1" class="govuk-link govuk-pagination__link">1</a></li>
            <li class="govuk-pagination__item" aria-label="Page 2"><a href="?page=2" class="govuk-link govuk-pagination__link">2</a></li>
            <li class="govuk-pagination__item" aria-label="Page 3"><a href="?page=3" class="govuk-link govuk-pagination__link">3</a></li>
          </ul>
        HTML
      end

      it "does not return previous link when on the first page" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        expect(doc.css("div.govuk-pagination__prev")).to be_empty
      end

      it "does not display the icon without previous link" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        link = doc.css("a.govuk-pagination__link").first
        expect(link["rel"]).not_to eq("prev")
      end
    end

    context "with next page link" do
      let(:pages) { 3 }
      let(:govuk_pagination_html) do
        <<~HTML
          <ul class="govuk-pagination__list">
            <li class="govuk-pagination__item" aria-label="Page 1"><a href="?page=1" class="govuk-link govuk-pagination__link">1</a></li>
            <li class="govuk-pagination__item govuk-pagination__item--current" aria-label="Page 2"><a href="?page=2" class="govuk-link govuk-pagination__link">2</a></li>
            <li class="govuk-pagination__item" aria-label="Page 3"><a href="?page=3" class="govuk-link govuk-pagination__link">3</a></li>
          </ul>
          <div class="govuk-pagination__next"><a href="?page=3" class="govuk-link govuk-pagination__link" rel="next"><span class="govuk-pagination__link-title govuk-pagination__link-title--decorated">Next<span class="govuk-visually-hidden"> page</span></span><svg class="govuk-pagination__icon govuk-pagination__icon--next"</svg></a></div>
        HTML
      end

      it "returns next link when on the second page" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        link = doc.css("a.govuk-pagination__link").last
        expect(link["rel"]).to eq("next")
      end

      it "displays the icon within next link" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        icon = doc.css("a.govuk-pagination__link").last
        expect(icon.css("svg.govuk-pagination__icon--next")).not_to be_empty
      end
    end

    context "without next page link" do
      let(:pages) { 3 }
      let(:govuk_pagination_html) do
        <<~HTML
          <ul class="govuk-pagination__list">
            <li class="govuk-pagination__item" aria-label="Page 1"><a href="?page=1" class="govuk-link govuk-pagination__link">1</a></li>
            <li class="govuk-pagination__item" aria-label="Page 2"><a href="?page=2" class="govuk-link govuk-pagination__link">2</a></li>
            <li class="govuk-pagination__item  govuk-pagination__item--current" aria-label="Page 3"><a href="?page=3" class="govuk-link govuk-pagination__link">3</a></li>
          </ul>
        HTML
      end

      it "does not return next link when on the last page" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        link = doc.css("a.govuk-pagination__link").last
        expect(link["rel"]).not_to eq("next")
      end

      it "does not display the next icon when no next link" do
        doc = Nokogiri::HTML::DocumentFragment.parse(result)
        icon = doc.css("a.govuk-pagination__link").last
        expect(icon.css("svg.govuk-pagination__icon--next")).to be_empty
      end
    end
  end
end
