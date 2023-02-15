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

    year = value[1]
    month = value[2]
    day = value[3]
    @date_from = begin
      Date.new(year, month, day)
    rescue TypeError, Date::Error
      value
    end
  end

  def date_to=(value)
    return if value.nil?

    year = value[1]
    month = value[2]
    day = value[3]
    @date_to = begin
      Date.new(year, month, day)
    rescue TypeError, Date::Error
      value
    end
  end

  def results
    scope = nil

    terms.each do |term|
      clause = Case.for_term(term)
      scope = scope.nil? ? clause : scope.or(clause)
    end

    if date_from.present?
      scope = scope.from_date(date_from)
    end

    if date_to.present?
      scope = scope.to_date(date_to)
    end

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
  end
end
