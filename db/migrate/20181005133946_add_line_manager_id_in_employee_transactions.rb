class AddLineManagerIdInEmployeeTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :old_line_manager_id, 	:integer
  	add_column :employee_transaction_histories, :new_line_manager_id, 	:integer
  end
end
