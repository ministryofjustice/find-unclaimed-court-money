class CreateCases < ActiveRecord::Migration[7.0]
  def change
    create_table :cases do |t|
      t.string :account_number
      t.string :year_carried_over
      t.string :case_name
      t.string :date_account_opened
      t.string :credit_details
      t.date :case_date
      t.timestamps
    end
  end
end
