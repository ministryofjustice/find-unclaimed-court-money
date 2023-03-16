class Search
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveRecord::AttributeAssignment

  attr_accessor :keywords
  attr_reader :date_from, :date_to

  validates :keywords, presence: true, length: { minimum: 3 }
  validate :validate_dates

  def date_from=(value)
    if value.nil?
      @date_from = Date.new(1700, 1, 1)
      puts "Date from - default: #{@date_from}"
    else
      year = value[1]
      month = value[2]
      day = value[3]

      @date_from = begin
        Date.new(year, month, day)
      rescue TypeError, Date::Error
        value
      end
      puts "Date from - user input: #{@date_from}"
    end
  end

  def date_to=(value)
    if value.nil?
      @date_to = Date.today
      puts "Default date to: #{@date_to}"
    else
      year = value[1]
      month = value[2]
      day = value[3]

      @date_to = begin
        Date.new(year, month, day)
      rescue TypeError, Date::Error
        value
      end
      puts "Date to - user input: #{@date_to}"
    end
  end

  def results
    scope = nil

    terms.each do |term|
      clause = Case.for_term(term)
      scope = scope.nil? ? clause : scope.or(clause)
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

    if date_from.is_a?(Date) && date_to.is_a?(Date)
      errors.delete(:keywords)
    end
  end
end
