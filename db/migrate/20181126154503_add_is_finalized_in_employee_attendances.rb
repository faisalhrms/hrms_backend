class AddIsFinalizedInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :is_finalized, :boolean, :default => false
  end
end
