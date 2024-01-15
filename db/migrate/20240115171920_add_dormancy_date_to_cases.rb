class AddDormancyDateToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :dormancy_date, :string
  end
end
