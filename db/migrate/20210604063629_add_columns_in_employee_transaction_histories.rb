class AddColumnsInEmployeeTransactionHistories < ActiveRecord::Migration[7.1]
  def change
    add_column  :employee_transaction_histories,  :old_hod_id,  :integer
    add_column  :employee_transaction_histories,  :new_hod_id,  :integer
  end
end
