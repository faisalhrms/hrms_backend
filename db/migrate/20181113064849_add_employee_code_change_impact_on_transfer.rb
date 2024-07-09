class AddEmployeeCodeChangeImpactOnTransfer < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :new_employee_code, :string
  	add_column :employee_transaction_histories, :old_employee_code, :string
  	add_column :employee_transaction_histories, :remarks, 					:text, :default => ""
  end
end
