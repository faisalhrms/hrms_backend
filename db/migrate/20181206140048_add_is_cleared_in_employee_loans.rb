class AddIsClearedInEmployeeLoans < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_loans, :is_cleared, :boolean, :default => false
  end
end
