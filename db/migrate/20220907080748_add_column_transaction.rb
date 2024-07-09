class AddColumnTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :attendance_execution_transactions, :department_id, :text, default: ""
    add_column :attendance_execution_transactions, :department_name, :text, default: ""
  end
end
