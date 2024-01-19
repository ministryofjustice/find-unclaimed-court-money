class RenameFinalClaimDateColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :cases, :final_claim_date, :initial_dormancy
  end
end
