class Search
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveRecord::AttributeAssignment

  attr_accessor :keywords, :date_from, :date_to

  validates :keywords, presence: true, length: { minimum: 3 }
  validate :validate_dates

  def results
    # title = Model.arel_table[:title]
    # Model.where(title.matches("%#{query}%"))
    Case.where("lower(case_name) LIKE ?", "%#{keywords.downcase}%")
  end

  private

  def validate_dates
    if date_from.present?
      from_date = Date.parse(date_from) rescue "invalid"
      if from_date == "invalid"
        errors.add(:date_from, :invalid)
      end
    end

    if date_to.present?
      to_date = Date.parse(date_to) rescue "invalid"
      if to_date == "invalid"
        errors.add(:date_to, :invalid)
      end
    end
  end
end
