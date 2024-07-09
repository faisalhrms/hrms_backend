class AddResignationInEmployeeTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_transaction_histories, :resign_date, 		:date
  end
end
