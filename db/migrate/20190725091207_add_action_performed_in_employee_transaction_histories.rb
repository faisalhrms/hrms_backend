class AddActionPerformedInEmployeeTransactionHistories < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :action_performed, :string
  end
end
