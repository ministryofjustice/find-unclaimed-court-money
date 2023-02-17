class MakeCaseAccountNumberUnique < ActiveRecord::Migration[7.0]
  def change
    add_index :cases, :account_number, unique: true
  end
end
