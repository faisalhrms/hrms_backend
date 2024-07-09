class AddIsLeaveWithoutPayInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :is_leave_without_pay, :boolean, :default => false
  end
end
