class AddProbationExtensionDaysInEmployeeTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :probation_extension_days, 	:float, :default => 0.0
  	add_column :employee_transaction_histories, :old_confimration_due_date, :datetime
		add_column :employee_transaction_histories, :new_confimration_due_date, :datetime
  end
end
