class Search
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveRecord::AttributeAssignment

  attr_accessor :keywords
  attr_reader :date_from, :date_to

  validates :keywords, presence: true, length: { minimum: 3 }
  validate :validate_dates

  def date_from=(value)
    @date_from = ActiveRecord::Type::Date.new.cast(value)
  end

  def date_to=(value)
    @date_to = ActiveRecord::Type::Date.new.cast(value)
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
    keywords.downcase.split(",").map(&:strip)
  end

  def validate_dates
    if date_from.present?
      unless date_from.is_a? Date
        errors.add(:date_from, :invalid)
      end
    end

    if date_to.present?
      unless date_to.is_a? Date
        errors.add(:date_to, :invalid)
      end
    end
  end
end
