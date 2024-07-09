class AddTransferInEmployeeTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :transfer_type, 		:string
  	add_column :employee_transaction_histories, :old_location_id, 	:integer
  	add_column :employee_transaction_histories, :new_location_id, 	:integer
  	add_column :employee_transaction_histories, :old_branch_id, 		:integer
  	add_column :employee_transaction_histories, :new_branch_id, 		:integer
  	add_column :employee_transaction_histories, :old_department_id, :integer
  	add_column :employee_transaction_histories, :new_department_id, :integer
  end
end
