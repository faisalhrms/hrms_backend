class AddIsFlexiInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :is_flexi, :boolean, :default => false
  end
end
