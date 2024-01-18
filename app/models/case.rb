class Case < ApplicationRecord
  validates :account_number, presence: true, uniqueness: true

  scope :from_date, ->(date) { where(case_date: date..) }
  scope :to_date, ->(date) { where(case_date: ..date) }
  scope :carried_over, ->(year) { where(year_carried_over: year) }
  scope :for_term, ->(term) { where("LOWER(case_name) LIKE :term OR LOWER(credit_details) LIKE :term OR LOWER(account_number) LIKE :term OR LOWER(dormancy_date) LIKE :term OR LOWER(final_claim_date) LIKE :term", { term: "%#{term.downcase}%" }) }
end
