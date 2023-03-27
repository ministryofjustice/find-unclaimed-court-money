class Search
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveRecord::AttributeAssignment

  attr_accessor :keywords
  attr_reader :date_from, :date_to

  validates :keywords, presence: true, length: { minimum: 3 }
  validate :validate_dates

  def date_from=(value)
    return if value.nil?

    @date_from = build_date(value)
  end

  def date_to=(value)
    return if value.nil?

    @date_to = build_date(value)
  end

  def results
    scope = nil

    terms.each do |term|
      clause = Case.for_term(term)
      scope = scope.nil? ? clause : scope.or(clause)
    end

    scope = Case if scope.nil?
    scope = scope.from_date(date_from)
    scope = scope.to_date(date_to)
    scope.order(case_date: :desc)
  end

private

  def terms
    keywords.split(",").map(&:strip)
  end

  def validate_dates
    if date_from.is_a?(Hash)
      errors.add(:date_from, :invalid)
    end

    if date_to.is_a?(Hash)
      errors.add(:date_to, :invalid)
    end

    if date_from.is_a?(Date) && date_to.is_a?(Date)
      errors.delete(:keywords)
    end
  end

  def build_date(value)
    year = value[1]
    month = value[2]
    day = value[3]

    Date.new(year, month, day)
  rescue TypeError, Date::Error
    value
  end
end
