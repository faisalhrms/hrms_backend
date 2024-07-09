class AddSubDepartmentIdInEmployeeTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :old_sub_department_id, 	:integer
  	add_column :employee_transaction_histories, :new_sub_department_id, 	:integer
  end
end
