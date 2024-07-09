class RemoveColumn < ActiveRecord::Migration[7.1]
  def change
    remove_column :attendance_execution_transactions, :department_id, :integer
    remove_column :attendance_execution_transactions, :department_name, :string
  end
end
