class SetNotNullColumns < ActiveRecord::Migration[7.0]
  def change
    change_column_null :cases, :account_number, false
    change_column_null :cases, :year_carried_over, false
    change_column_null :cases, :case_name, false
    change_column_null :cases, :date_account_opened, false
    change_column_null :cases, :case_date, false
  end
end
