class RenameDormancyDateColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :cases, :dormancy_date, :last_claim_date
  end
end
