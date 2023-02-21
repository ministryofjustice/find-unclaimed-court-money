class Case < ApplicationRecord
  validates :account_number, presence: true, uniqueness: true

  scope :from_date, ->(date) { where(case_date: date..) }
  scope :to_date, ->(date) { where(case_date: ..date) }
  scope :for_term, ->(term) { where("LOWER(case_name) LIKE :term OR LOWER(credit_details) LIKE :term OR LOWER(account_number) LIKE :term", { term: "%#{term.downcase}%" }) }
end
