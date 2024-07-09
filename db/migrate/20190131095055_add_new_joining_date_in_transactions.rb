class AddNewJoiningDateInTransactions < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_transaction_histories, :old_joining_date, :datetime
  	add_column :employee_transaction_histories, :new_joining_date, :datetime
  end
end
