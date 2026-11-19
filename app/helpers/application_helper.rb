module ApplicationHelper
  def to_csv_path(url)
    url.gsub("?", ".csv?")
  end

  def govuk_pagination_with_link_labels(pagy:, **kwargs)
    html = govuk_pagination(pagy: pagy, **kwargs)
    return if html.blank?

    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    doc.css("li.govuk-pagination__item").each do |li|
      li.remove_attribute("aria-label")

      link = li.at_css("a.govuk-pagination__link")
      if link
        page_number = link.text.strip
        link["aria-label"] = "Page #{page_number}"
      end
    end

    doc.to_html.html_safe
  end
end
