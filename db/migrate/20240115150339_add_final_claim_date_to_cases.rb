class AddFinalClaimDateToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :final_claim_date, :date
  end
end
