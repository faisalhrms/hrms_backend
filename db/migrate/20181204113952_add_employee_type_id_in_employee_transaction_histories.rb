class AddEmployeeTypeIdInEmployeeTransactionHistories < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :old_employee_type_id, :integer
		add_column :employee_transaction_histories, :new_employee_type_id, :integer
  end
end
