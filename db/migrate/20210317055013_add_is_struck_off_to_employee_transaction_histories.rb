class AddIsStruckOffToEmployeeTransactionHistories < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_transaction_histories, :is_struck_off, :boolean, default: false
  end
end
